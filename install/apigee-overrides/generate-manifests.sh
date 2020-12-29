#!/bin/sh

export OVERRIDES=overrides/overrides-srinandans-hybrid.yaml
export ORG=$(cat $OVERRIDES | yq -r '.org')

apigeectl init -f $OVERRIDES --dry-run=client --print-yaml >> apigee-controller.yaml

components=("org" "datastore" "telemetry")
len=${#components[@]}
for (( i=0; i<$len; i++ ));
do
apigeectl apply -f $OVERRIDES --${components[$i]} --dry-run=client --print-yaml >> apigee-${components[$i]}.yaml
done


cat $OVERRIDES | yq -r '.envs | .[].name' | while read -r a; do apigeectl apply -f $OVERRIDES --env $a --dry-run=client --print-yaml >> apigee-srinandans-hybrid-$a.yaml; done

apigeectl apply -f $OVERRIDES --settings=virtualhosts --dry-run=client --print-yaml >> apigee-virtualhosts.yaml

mv apigee-org.yaml apigee-$ORG.yaml