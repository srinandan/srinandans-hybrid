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

rm ./overlays/instance1/org.yaml
rm ./overlays/instance1/org-sa.yaml
rm ./overlays/instance1/environments/prod1/env.yaml
rm ./overlays/instance1/environments/prod1/kustomization.yaml
rm ./overlays/instance1/workload-identity/annotate.yaml
rm ./overlays/instance1/metrics/metrics.yaml
rm ./overlays/instance1/envgroup/certificate.yaml
rm ./overlays/instance1/envgroup/apigeerouteconfig.yaml
rm ./overlays/instance1/secrets/kustomization.yaml
rm ./overlays/instance1/kustomization.yaml
