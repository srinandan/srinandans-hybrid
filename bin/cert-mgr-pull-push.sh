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

CERT_MANAGER_VER="v1.5.4"
docker pull quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VER}
docker pull quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VER}
docker pull quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VER}

docker tag quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-controller:${CERT_MANAGER_VER}
docker tag quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-cainjector:${CERT_MANAGER_VER}
docker tag quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-webhook:${CERT_MANAGER_VER}

docker push gcr.io/${PROJECT_ID}/cert-manager-controller:${CERT_MANAGER_VER}
docker push gcr.io/${PROJECT_ID}/cert-manager-cainjector:${CERT_MANAGER_VER}
docker push gcr.io/${PROJECT_ID}/cert-manager-webhook:${CERT_MANAGER_VER}
