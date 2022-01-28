# GKE cluster Setup

Use these instructions to setup a GKE cluster for setting up Apigee hybrid.

## Pre-requisite

- Terraform

## Steps

```sh
terraform init
terraform plan --var-file="cluster.tfvars" -var=project_id=$PROJECT_ID
terraform apply --var-file="cluster.tfvars" -var=project_id=$PROJECT_ID
```