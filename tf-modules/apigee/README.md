# Apigee setup

Use these instructions to setup an Apigee hybrid organization, environment and environment group.

## Pre-requisite

- Terraform


## Steps

```sh
terraform init
terraform plan --var-file="hybrid.tfvars" -var=project_id=$PROJECT_ID
terraform apply --var-file="hybrid.tfvars" -var=project_id=$PROJECT_ID
```