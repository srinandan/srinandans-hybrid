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

# initalize other variables
source ${APIGEE_HOME}/bin/vars.sh

# validate prerequisites
. ${APIGEE_HOME}/bin/validate.sh "$@"

# step 1: prepare the kustomize files

# a: generate kustomize manifests for the controller
. ${APIGEE_HOME}/bin/generateControllerKustomize.sh

# b: generate kustomize manifests for the org
. ${APIGEE_HOME}/bin/generateOrgKustomize.sh

# c: generate env kustomize manifests from templates
. ${APIGEE_HOME}/bin/generateEnvKustomize.sh

echo "Kustomize manifest files generated. "
read -p "Do you wish to process with the installation? Select No if you wish to change default Kustomize settings:  " -n 1 -r
echo  ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# step 2. install cert manager
helm repo add jetstack https://charts.jetstack.io && helm repo update

# if using a custom repo, also add --set image.repository=gcr.io/myproject/cert-manager
CERT_MANAGER_CHECK=$(kubectl get pods -n cert-manager --field-selector=status.phase=Running -l=app=cert-manager --output=jsonpath={.items..metadata.name} | grep cert-manager | xargs | wc -l)
if [ $CERT_MANAGER_CHECK -gt 0 ]; then
  echo "Cert Manager is already installed, skipping install"
else
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.2 --set installCRDs=true --set nodeSelector."cloud\.google\.com/gke-nodepool"=${APIGEE_RUNTIME_NP_VALUE} && kubectl wait deployments/cert-manager -n cert-manager --for condition=available --timeout 60s
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

# step 4: install CA cert in primary region only
if [[ -z $EXPAND_REGION ]]; then
  kubectl apply -f ${APIGEE_HOME}/cluster/apigee-selfsigned-clusterissuer.yaml && kubectl wait clusterissuer/selfsigned --for condition=ready --timeout=60s

  kubectl apply -f ${APIGEE_HOME}/primary/apigee-ca-certificate.yaml && kubectl wait certificates/apigee-ca -n cert-manager --for condition=ready --timeout=60s
else
  # NOTE: Before running this command, obtian the keys from get-tls-keys.sh
  kubectl create secret tls apigee-ca -n cert-manager --cert=tls.crt --key=tls.key
fi

# step 5: install the kustomize manifests
. ${APIGEE_HOME}/bin/installKustomize.sh

# step 6: This step associates GSA with KSA and adds workloadIdentityUser role to the GSA. If not using workload identity, skip the step
if [[ -z $NO_WORKLOAD_IDENTITY ]]; then
  . ${APIGEE_HOME}/bin/workloadIdentity.sh
fi

# step 7: Wait for environments to be ready
echo "Waiting for Apigee Environment "${ENV_NAME}" to be ready"
kubectl wait apigeeenvironments/${ENV} -n apigee --for=jsonpath='{.status.state}'=running --timeout 120s

echo "Installation completed successfully!"

EXTERNAL_IP=$(kubectl get svc -n apigee apigee-istio-ingressgateway --output jsonpath='{.status.loadBalancer.ingress[0].ip}' | xargs)
EXTERNAL_HOST_NAME="api."${ORG_NAME}".example"

echo "If the ingress configurations were not customized, you can test your API call with this: curl -kv https://${EXTERNAL_HOST_NAME} --resolve \"${EXTERNAL_HOST_NAME}:443:${EXTERNAL_IP}\""
