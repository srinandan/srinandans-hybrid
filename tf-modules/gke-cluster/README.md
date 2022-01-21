# GKE cluster Setup

## Pre-requisite

- Terraform


## Steps

1. Login with your credentials and select the appropriate project using `gcloud init`
2. Export the following variables
```sh
export PROJECT_ID=<GCP Project ID>
export PROJECT_NUMBER=<GCP Project Number>
export NETWORK=<VPC Network>
export SUBNETWORK=<VPC Subnet Name>
export REGION=<REGION>
export GKE_CLUSTER_NAME=<GKE Cluster Name>
```
3. Run `./prepare.sh` which creates terraform.tfvars 
4. Run `terraform init`
5. Run `terraform plan`
6. Run `terraform apply`


