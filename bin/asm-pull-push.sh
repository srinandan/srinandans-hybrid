#!/bin/bash
# Copyright 2022 Google LLC
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


source ${APIGEE_HOME}/bin/vars.sh

docker pull gcr.io/gke-release/asm/pilot:${ASM_VERSION}
docker pull gcr.io/gke-release/asm/proxyv2:${ASM_VERSION}

docker tag gcr.io/gke-release/asm/pilot:${ASM_VERSION} gcr.io/${PROJECT_ID}/asm/pilot:${ASM_VERSION}
docker tag gcr.io/gke-release/asm/proxyv2:${ASM_VERSION} gcr.io/${PROJECT_ID}/asm/proxyv2:${ASM_VERSION}

docker push gcr.io/${PROJECT_ID}/asm/pilot:${ASM_VERSION}
docker push gcr.io/${PROJECT_ID}/asm/proxyv2:${ASM_VERSION}

_CI_ASM_IMAGE_LOCATION=gcr.io/${PROJECT_ID}/asm
