// main.tf

module "apigee" {
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/apigee-organization"
  project_id          = var.project_id
  analytics_region    = var.analytics_region
  runtime_type        = "HYBRID"
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
}
