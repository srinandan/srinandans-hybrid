#!/bin/bash

roles=("roles/logging.logWriter" "roles/monitoring.metricWriter" "roles/storage.objectAdmin" "roles/apigee.analyticsAgent" "roles/apigee.synchronizerManager" "roles/apigeeconnect.Agent" "roles/apigee.runtimeAgent")

len=${#roles[@]}

for (( i=0; i<=$len; i++ ));
do
  gcloud projects add-iam-policy-binding ${PROJECT_ID} --role ${roles[${i}]} --member "serviceAccount:${GSA}@${PROJECT_ID}.iam.gserviceaccount.com" --project=${PROJECT_ID}
done

kubectl get sa -n apigee | grep apigee | awk '{print $1}' | while read line ; do gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member "serviceAccount:$PROJECT_ID.svc.id.goog[apigee/$line]" $GSA@$PROJECT_ID.iam.gserviceaccount.com --project=${PROJECT_ID} ; done
