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

# run one per env group
mkdir -p ./overlays/${INSTANCE_ID}/envgroups/${ENV_GROUP}
cp ./overlays/templates/envgroup-kustomization.yaml ./overlays/${INSTANCE_ID}/envgroups/${ENV_GROUP}/kustomization.yaml
envsubst < ./overlays/templates/envgroups-kustomization.tmpl > ./overlays/${INSTANCE_ID}/envgroups/kustomization.yaml
envsubst < ./overlays/templates/certificate.tmpl > ./overlays/${INSTANCE_ID}/envgroups/${ENV_GROUP}/certificate.yaml
envsubst < ./overlays/templates/apigeerouteconfig.tmpl > ./overlays/${INSTANCE_ID}/envgroups/${ENV_GROUP}/apigeerouteconfig.yaml

#this is only necessary if the wildcard-gateway component is enabled
envsubst < ./overlays/templates/wildcard-gateway.tmpl > ./overlays/${INSTANCE_ID}/wildcard-gateway/wildcard-gateway.yaml
