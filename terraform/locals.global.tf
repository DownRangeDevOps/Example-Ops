locals {
  region     = var.environment_region == "" ? var.global_default_region : var.environment_region
  project_id = "${var.global_org_name}-${var.environment}"
}
