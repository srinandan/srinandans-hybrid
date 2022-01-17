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

set -e

#**
# @brief    Displays usage details.
#
usage() {
    echo -e "$*\n usage: $(basename "$0")" \
        "-o <org> -e <env> -eg <envgroup> -i <instance> --cluster-name <name> --cluster-region <region>\n" \
        "example: $(basename "$0") -o my-org -e test -eg default -i instance1 --cluster-name k8s1 --cluster-region <region>\n" \
        "Parameters:\n" \
        "-o --org         : Apigee organization name (mandatory parameter)\n" \
        "-e --env         : Apigee environment name (mandatory parameter)\n" \
        "-eg --envgroup   : Apigee component name (optional parameter; defaults to default)\n" \
        "-i --instance    : Apigee instance name (optional parameter; defaults to instance1)\n" \
        "-v --apigeever   : Apigee hybrid version; defaults to 1.6.3\n" \
        "--cluster-name   : Kubernetes cluster name\n" \
        "--cluster-region : Kubernetes cluster region"
    exit 1
}

### Start of mainline code ###

PARAMETERS=()
while [[ $# -gt 0 ]]
do
    param="$1"

    case $param in
        -o|--org)
        export ORG_NAME="$2"
        export PROJECT_ID="$2"
        shift
        shift
        ;;
        -e|--env)
        export ENV_NAME="$2"
        shift
        shift
        ;;
        -eg|--envgroup)
        export ENV_GROUP="$2"
        shift
        shift
        ;;
        -v|--apigeever)
        export APIGEE_VERSION="$2"
        shift
        shift
        ;;
        -i|--instance)
        export INSTANCE_ID="$2"
        shift
        shift
        ;;
        --cluster-name)
        export CLUSTER_NAME="$2"
        shift
        shift
        ;;
        --cluster-region)
        export CLUSTER_REGION="$2"
        shift
        shift
        ;;
        *)
        PARAMETERS+=("$1")
        shift
        ;;
    esac
done

set -- "${PARAMETERS[@]}"

if [[ -z $ORG_NAME ]]; then
    usage "org name is a mandatory parameter"
fi

if [[ -z $ENV_NAME ]]; then
    usage "env name is a mandatory parameter"
fi

if [[ -z $ENV_GROUP ]]; then
    usage "env group is a mandatory parameter"
fi

if [[ -z $INSTANCE_ID ]]; then
    usage "instance id is a mandatory parameter"
fi

if [[ -z $CLUSTER_NAME ]]; then
    usage "cluster name is a mandatory parameter"
fi

if [[ -z $CLUSTER_REGION ]]; then
    usage "cluster region is a mandatory parameter"
fi

if [[ -z $APIGEE_VERSION ]]; then
    export APIGEE_VERSION=1.6.3
fi

if [ $OSTYPE == "linux-gnu"* ]; then
  echo "WARNING: this script has tested only on bash on Linux. You may encounter problems on other platforms"
fi


gcloud version 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on gcloud. Please install gcloud and re-run the command"
  exit 1
fi

gcloud config set project ${PROJECT_ID}

openssl version 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on openssl. Please install openssl and re-run the command"
  exit 1
fi

helm version 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on helm for cert-manager install. Please install helm and re-run the command"
  exit 1
fi

kubectl version 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on helm for cert-manager install. Please install helm and re-run the command"
  exit 1
fi

MIN_KUBECTL_VER=23
KUBECTL_VER=$(kubectl version --short=true 2> /dev/null | head -n 1 | awk '{print $3}' | cut -d '.' -f2)
if [ "$KUBECTL_VER" -lt "$MIN_KUBECTL_VER" ]; then
  echo "this script depends on kubectl 1.23 or higher"
  exit 1
fi

gcloud alpha apigee environments describe $ENV_NAME --organization=$ORG_NAME 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on control plane entities like org, env and envgroup to exist. Please create them and re-run the command"
  exit 1
fi

COUNT_APIGEE_RUNTIME=$(kubectl get node --selector='cloud.google.com/gke-nodepool=apigee-runtime' | wc -l)
if [ ${COUNT_APIGEE_RUNTIME} -lt 1 ]; then
  echo "WARNING: Kubernetes node pool for runtime wasnt detected. Looking for nodes labeled: cloud.google.com/gke-nodepool=apigee-runtime"
fi

COUNT_APIGEE_DATA=$(kubectl get node --selector='cloud.google.com/gke-nodepool=apigee-data' | wc -l)
if [ ${COUNT_APIGEE_DATA} -lt 1 ]; then
  echo "WARNING: Kubernetes node pool for data wasnt detected. Looking for nodes labeled: cloud.google.com/gke-nodepool=apigee-data"
fi

echo "All mandatory pre-reqs were met, proceeding with install!"

