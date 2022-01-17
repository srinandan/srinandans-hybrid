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

#export CLUSTER_REGION=us-west1
#export CLUSTER_NAME=srinandans-hybrid
#export PROJECT_ID=$(gcloud config get-value project)
export ASM_MINOR_VERSION=12

export HUB=gcr.io/apigee-release/hybrid
#export APIGEE_VERSION=1.6.3

#export INSTANCE_ID=instance1

# Google service account name
export GSA=apigee

#export ORG_NAME=$PROJECT_ID
#export ENV_GROUP=default

#if cassandra backup is enabled, uncomment this
#export GCS_BUCKET=my-bucket

####
export VERSION=${APIGEE_VERSION//./}
export UC_ORG_NAME=$(echo "${ORG_NAME}" | awk '{print toupper($0)}')

orglen=${#ORG_NAME}

ORGHASH=$(printf "$ORG_NAME" | openssl dgst -sha256 | awk '{print $2}' | cut -c1-7)

if [[ orglen -gt 15 ]]; then
  ORGSHORTNAME=`echo $ORG_NAME | cut -c1-15`
else
  ORGSHORTNAME=$ORG_NAME
fi

export ORG=$ORGSHORTNAME-$ORGHASH

source ${APIGEE_HOME}/bin/env-vars.sh

# for multi-region
# export SEED_HOST=10.0.0.1
# export DATA_CENTER=dc2
