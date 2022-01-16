#!/bin/bash

gcloud version 2>&1 >/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "this script depends on gcloud. Please install gcloud and re-run the command"
  exit 1
fi

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

echo "all pre-reqs passed!"

