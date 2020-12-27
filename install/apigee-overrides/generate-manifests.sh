#!/bin/sh

export OVERRIDES=overrides-srinandans-hybrid.yaml

export ORG=$(cat $OVERRIDES | yq -r '.org')

apigeectl init -f $OVERRIDES --dry-run=true --print-yaml >> apigee-init.yaml

components=($ORG "datastore" "telemetry")
len=$( ${#components[@]} )
for (( i=0; i<=$len; i++ ));
do
apigeectl apply -f $OVERRIDES --${i} --dry-run --print-yaml >> apigee-${i}.yaml
done


cat $OVERRIDES | yq -r '.envs | .[].name' | while read -r a; do apigeectl apply -f $OVERRIDES --env $a --dry-run=client --print-yaml >> apigee-srinandans-hybrid-$a; done

apigeectl apply -f $OVERRIDES --settings=virtualhosts >> apigee-virtualhosts.yaml