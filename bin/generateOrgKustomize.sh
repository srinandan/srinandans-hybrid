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

mkdir -p ${APIGEE_HOME}/overlays/${INSTANCE_ID}
cp -r ${APIGEE_HOME}/overlays/org-components/* ${APIGEE_HOME}/overlays/${INSTANCE_ID}/

envsubst < ${APIGEE_HOME}/overlays/templates/org.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/org.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-sa.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/org-sa.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-secrets.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/secrets/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-gsa-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/google-service-accounts/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-multi-gsa-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/multi-google-service-accounts/kustomization.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-gsa.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/google-service-accounts/org.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/org-gsa.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/multi-google-service-accounts/org.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/metrics.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/metrics/metrics.yaml
envsubst < ${APIGEE_HOME}/overlays/templates/redis.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/redis.yaml

#if Cassandra backup is enabled, uncomment this
#envsubst < ${APIGEE_HOME}/overlays/templates/apigee-cassandra-backup-cronjob.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/cass-backup/apigee-cassandra-backup-cronjob.yaml
#envsubst < ${APIGEE_HOME}/overlays/templates/cass-backup-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/cass-backup/kustomization.yaml

# disable if not using workload identity
envsubst < ${APIGEE_HOME}/overlays/templates/annotate.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/workload-identity/annotate.yaml

# run one per env group
. ${APIGEE_HOME}/bin/generateEnvGrpKustomize.sh

envsubst < ${APIGEE_HOME}/overlays/templates/instance-kustomization.tmpl > ${APIGEE_HOME}/overlays/${INSTANCE_ID}/kustomization.yaml

# generate configuration for envoy filters
envsubst < ${APIGEE_HOME}/overlays/templates/envoyfilters-kustomization.tmpl > ${APIGEE_HOME}/overlays/envoyfilters/kustomization.yaml

#kustomize build ${APIGEE_HOME}/overlays/${INSTANCE_ID} -o ${INSTANCE_ID}.yaml
