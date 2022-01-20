#!/bin/bash

if [[ -z $SEED_HOST ]]; then
  echo "SEED_HOST must be set in vars.sh when expanding Apigee to a new region"
  exit 1
fi

if [[ -z $DATA_CENTER ]]; then
  echo "DATA_CENTER must be set in vars.sh when expanding Apigee to a new region"
  exit 1
fi
