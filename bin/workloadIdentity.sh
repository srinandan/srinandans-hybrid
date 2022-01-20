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


roles=("roles/logging.logWriter" "roles/monitoring.metricWriter" "roles/storage.objectAdmin" "roles/apigee.analyticsAgent" "roles/apigee.synchronizerManager" "roles/apigeeconnect.Agent" "roles/apigee.runtimeAgent")

len=${#roles[@]}

for (( i=0; i<=$len; i++ ));
do
  gcloud projects add-iam-policy-binding ${PROJECT_ID} --role ${roles[${i}]} --member "serviceAccount:${GSA}@${PROJECT_ID}.iam.gserviceaccount.com" --project=${PROJECT_ID}
done

kubectl get sa -n apigee | grep apigee | awk '{print $1}' | while read line ; do gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member "serviceAccount:$PROJECT_ID.svc.id.goog[apigee/$line]" $GSA@$PROJECT_ID.iam.gserviceaccount.com --project=${PROJECT_ID} ; done
