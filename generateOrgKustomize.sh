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

#source vars.sh

envsubst < ./overlays/templates/org.tmpl > ./overlays/instance1/org.yaml
envsubst < ./overlays/templates/org-sa.tmpl > ./overlays/instance1/org-sa.yaml
envsubst < ./overlays/templates/org-secrets.tmpl > ./overlays/instance1/secrets/kustomization.yaml
envsubst < ./overlays/templates/metrics.tmpl > ./overlays/instance1/metrics/metrics.yaml

# disable if not using workload identity
envsubst < ./overlays/templates/annotate.tmpl > ./overlays/instance1/workload-identity/annotate.yaml

# run one per env group
envsubst < ./overlays/templates/certificate.tmpl > ./overlays/instance1/envgroup/certificate.yaml
envsubst < ./overlays/templates/apigeerouteconfig.tmpl > ./overlays/instance1/envgroup/apigeerouteconfig.yaml

envsubst < ./overlays/instance1/kustomization.tmpl > ./overlays/instance1/kustomization.yaml

#kustomize build overlays/instance1 -o instance1.yaml
