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

set -e

# path to the folder containing the scripts
export APIGEE_HOME=$(pwd)

# validate prerequisites
. ${APIGEE_HOME}/bin/validate.sh "$@"

# validate prerequisites for expanding region
. ${APIGEE_HOME}/bin/validate-expand.sh

# initalize other variables
source ${APIGEE_HOME}/bin/vars.sh

# step 1: prepare the kustomize files
. ${APIGEE_HOME}/bin/generateMultiRegionKustomize.sh

echo "Kustomize manifest files for multi-region generated. "
read -p "Do you wish to process with the installation? Select No if you wish to change default Kustomize settings:  " -n 1 -r
echo  ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# step 2. install cert manager
helm repo add jetstack https://charts.jetstack.io && helm repo update

CERT_MANAGER_CHECK=$(helm list -n cert-manager | grep deployed | grep cert-manager | wc -l)
if [ $CERT_MANAGER_CHECK -gt 1 ]; then
  echo "Cert Manager is already installed, skipping install\n"
else
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.2 --set installCRDs=true --set nodeSelector."c
loud\.google\.com/gke-nodepool"=apigee-runtime && kubectl wait deployments/cert-manager -n cert-manager --for condition=available --timeout 60s
fi

# step 3: install asm
# These instructions are for GKE. If installing on another platform, see here: https://cloud.google.com/service-mesh/docs/unified-install/install#amazon-eks

if [[ -z $SKIP_ASM ]]; then
    curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 > ${APIGEE_HOME}/bin/asmcli

    chmod +x ${APIGEE_HOME}/bin/asmcli

    . ${APIGEE_HOME}/bin/asmcli install \
    --project_id ${PROJECT_ID} \
    --cluster_name ${CLUSTER_NAME} \
    --cluster_location ${CLUSTER_REGION} \
    --fleet_id ${PROJECT_ID} \
    --enable_all \
    --ca mesh_ca

    # clean up asmcli
    rm ${APIGEE_HOME}/bin/asmcli
fi

# step 3: Create Apigee CA
#
# NOTE: Before running this command, obtian the keys from get-tls-keys.sh
kubectl create secret tls apigee-ca -n cert-manager --cert=tls.crt --key=tls.key

# step 4: install crds
kubectl create -f ${APIGEE_HOME}/cluster/crds && kubectl wait crd/apigeeenvironments.apigee.cloud.google.com --for condition=established --timeout=60s

# step 5: create cluster resources
kubectl apply -f ${APIGEE_HOME}/cluster

# step 6: install apigee controller. Controller kustomize scripts were already created.
kubectl apply -k ${APIGEE_HOME}/overlays/controller && kubectl wait deployments/apigee-controller-manager --for condition=available -n apigee-system --timeout=60s

# step 7: install apigee runtime instance (datastore, telemetry, redis and org)
kubectl apply -k ${APIGEE_HOME}/overlays/${INSTANCE_ID} && kubectl wait apigeeorganizations/${ORG} -n apigee --for=jsonpath='{.status.state}'=running --timeout 300s

# step 8: install the apigee environment
kubectl apply -k ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME} && kubectl wait apigeeenvironments/${ENV} -n apigee --for=jsonpath='{.status.state}'=running --timeout 120s

# step 9: Enable Apigee envoyfilters for ASM
kubectl apply -k ${APIGEE_HOME}/overlays/envoyfilters

echo "Installation completed successfully!"
