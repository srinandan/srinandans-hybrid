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

mkdir -p ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}
cp -r ./overlays/env-components/* ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/

# run one per environment name
envsubst < ./overlays/templates/env-kustomization.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/kustomization.yaml
envsubst < ./overlays/templates/env.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/env.yaml
envsubst < ./overlays/templates/env-gsa.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/google-service-accounts/env.yaml
envsubst < ./overlays/templates/env-gsa-kustomization.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/google-service-accounts/kustomization.yaml
envsubst < ./overlays/templates/env-secrets.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/secrets/kustomization.yaml

# disable if not using workload identity
envsubst < ./overlays/templates/annotate.tmpl > ./overlays/${INSTANCE_ID}/environments/${ENV_NAME}/workload-identity/annotate.yaml

#kustomize build overlays/instance1/environments/prod1 -o prod1.yaml
