#!/bin/sh
# Copyright 2020 Google LLC
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