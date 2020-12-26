#!/bin/sh

export OVERRIDES=overrides-srinandans-hybrid.yaml

apigeectl init -f $OVERRIDES --dry-run=true --print-yaml >> apigee-init.yaml

apigeectl apply -f $OVERRIDES --datastore --dry-run=true --print-yaml >> apigee-datastore.yaml

apigeectl apply -f $OVERRIDES --telemetry --dry-run=true --print-yaml >> apigee-telemetry.yaml

apigeectl apply -f $OVERRIDES --org --dry-run=true --print-yaml >> apigee-srinandans-hybrid.yaml

cat $OVERRIDES | yq -r '.envs | .[].name' | while read -r a; do apigeectl apply -f $OVERRIDES --env $a --dry-run=client --print-yaml >> apigee-srinandans-hybrid-$a; done