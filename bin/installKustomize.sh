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

if [[ -z $APIGEE_HOME ]]; then
    echo "APIGEE_HOME not set. Set the variable and re-run"
fi

# step 4: install CA cert in primary region only
kubectl apply -f ${APIGEE_HOME}/cluster/apigee-selfsigned-clusterissuer.yaml && kubectl wait clusterissuer/selfsigned --for condition=ready --timeout=60s

kubectl apply -f ${APIGEE_HOME}/primary/apigee-ca-certificate.yaml && kubectl wait certificates/apigee-ca -n cert-manager --for condition=ready --timeout=60s

# step 5: install crds
kubectl create -f ${APIGEE_HOME}/cluster/crds && kubectl wait crd/apigeeenvironments.apigee.cloud.google.com --for condition=established --timeout=60s

# step 6: create cluster resources
kubectl apply -f ${APIGEE_HOME}/cluster

# step 7: install apigee controller
kubectl apply -k ${APIGEE_HOME}/overlays/controller && kubectl wait deployments/apigee-controller-manager --for condition=available -n apigee-system --timeout=60s

# step 8: install apigee runtime instance (datastore, telemetry, redis and org)
kubectl apply -k ${APIGEE_HOME}/overlays/${INSTANCE_ID} && kubectl wait apigeeorganizations/${ORG} -n apigee --for=jsonpath='{.status.state}'=running --timeout 300s

# step 9: install the apigee environment
kubectl apply -k ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}

# step 10: Enable Apigee envoyfilters for ASM
kubectl apply -k ${APIGEE_HOME}/overlays/envoyfilters
