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

mkdir ./overlays/${INSTANCE_ID}
cp -r ./overlays/org-components/* ./overlays/${INSTANCE_ID}/

envsubst < ./overlays/templates/org.tmpl > ./overlays/${INSTANCE_ID}/org.yaml
envsubst < ./overlays/templates/org-sa.tmpl > ./overlays/${INSTANCE_ID}/org-sa.yaml
envsubst < ./overlays/templates/org-secrets.tmpl > ./overlays/${INSTANCE_ID}/secrets/kustomization.yaml
envsubst < ./overlays/templates/org-gsa-kustomization.tmpl > ./overlays/${INSTANCE_ID}/google-service-accounts/kustomization.yaml
envsubst < ./overlays/templates/org-gsa.tmpl > ./overlays/${INSTANCE_ID}/google-service-accounts/org.yaml
envsubst < ./overlays/templates/metrics.tmpl > ./overlays/${INSTANCE_ID}/metrics/metrics.yaml

#if Cassandra backup is enabled, uncomment this
#envsubst < ./overlays/templates/apigee-cassandra-backup-cronjob.tmpl > ./overlays/${INSTANCE_ID}/cass-backup/apigee-cassandra-backup-cronjob.yaml
#envsubst < ./overlays/templates/cass-backup-kustomization.tmpl > ./overlays/${INSTANCE_ID}/cass-backup/kustomization.yaml

# disable if not using workload identity
envsubst < ./overlays/templates/annotate.tmpl > ./overlays/${INSTANCE_ID}/workload-identity/annotate.yaml

# run one per env group
envsubst < ./overlays/templates/certificate.tmpl > ./overlays/certificates/certificate-${ENV_GROUP}.yaml
envsubst < ./overlays/templates/apigeerouteconfig.tmpl > ./overlays/${INSTANCE_ID}/envgroup/apigeerouteconfig.yaml

envsubst < ./overlays/templates/instance-kustomization.tmpl > ./overlays/${INSTANCE_ID}/kustomization.yaml

#kustomize build overlays/${INSTANCE_ID} -o ${INSTANCE_ID}.yaml
