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

mkdir -p ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}
cp -r ${APIGEE_HOME}/overlays/env-components/* ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/

# run one per environment name
envsubst < ${APIGEE_HOME}/overlays/templates/env-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/env.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env-gsa.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/google-service-accounts/env.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env-gsa.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/multi-google-service-accounts/env.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env-gsa-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/google-service-accounts/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env-multi-gsa-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/multi-google-service-accounts/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/env-secrets.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/secrets/kustomization.yaml

# disable if not using workload identity
envsubst < ${APIGEE_HOME}/overlays/templates/annotate.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/workload-identity/annotate.yaml

# generate node selector manifests
envsubst < ${APIGEE_HOME}/overlays/templates/env-nodeselector.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/environments/${ENV_NAME}/node-selector/env-nodeselector.yaml

#kustomize build overlays/instance1/environments/prod1 -o prod1.yaml
