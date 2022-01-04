#!/bin/bash
gcloud compute addresses create apigee-xlb --ip-version=IPv4 --global --project=${PROJECT_ID}
