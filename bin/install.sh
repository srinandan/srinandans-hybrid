#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# initalize variables
source vars.sh

# step 1. install cert manager
helm repo add jetstack https://charts.jetstack.io && helm repo update

# if using a custom repo, also add --set image.repository=gcr.io/myproject/cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.2 --set installCRDs=true --set nodeSelector."cloud\.google\.com/gke-nodepool"=apigee-runtime && kubectl wait deployments/cert-manager -n cert-manager --for condition=available --timeout 60s

# step 2: install asm
# These instructions are for GKE. If installing on another platform, see here: https://cloud.google.com/service-mesh/docs/unified-install/install#amazon-eks
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 > asmcli

chmod +x asmcli

./asmcli install \
  --project_id ${PROJECT_ID} \
  --cluster_name ${CLUSTER_NAME} \
  --cluster_location ${CLUSTER_REGION} \
  --fleet_id ${PROJECT_ID} \
  --enable_all \
  --ca mesh_ca

# step 3: install CA cert in primary region only
kubectl apply -f primary/apigee-ca-certificate.yaml && kubectl wait certificates/apigee-ca -n cert-manager --for condition=ready --timeout=60s

# step 4: install crds
kubectl create -f cluster/crds && kubectl wait crd/apigeeenvironments.apigee.cloud.google.com --for condition=established --timeout=60s

# step 5: create cluster resources
kubectl apply -f cluster

# step 6: install apigee controller
./generateControllerKustomize.sh
kubectl apply -k overlays/controller && kubectl wait deployments/apigee-controller-manager --for condition=available -n apigee-system --timeout=60s

# step 7: generate kustomize manifests from templates
./generateOrgKustomize.sh
# inspect the kustomization.yaml file in ./overlays/${INSTANCE_ID}. Enable or
# disable features as necessary

# step 8: install apigee runtime instance (datastore, telemetry, redis and org)
kubectl apply -k overlays/${INSTANCE_ID} && kubectl wait apigeeorganizations/${ORG} -n apigee --for=jsonpath='{.status.state}'=running --timeout 300s

# step 9: generate env kustomize manifests from templates
./generateEnvKustomize.sh

# step 10: install the apigee environment
kubectl apply -k overlays/${INSTANCE_ID}/environments/${ENV_NAME} && kubectl wait apigeeenvironments/${ENV} -n apigee --for=jsonpath='{.status.state}'=running --timeout 120s

# step 11: Enable Apigee envoyfilters for ASM
kubectl apply -k overlays/envoyfilters
