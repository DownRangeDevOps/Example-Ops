/******************************************
  Terraform backend
*******************************************/
terraform {
  backend "gcs" {
    prefix = "staging/oidc"
  }
}

/******************************************
  Local variables
*******************************************/
locals {
  # labels
  module_labels = {
    department = var.production_label_department
  }

  sanitized_module_labels = module.sanitize_labels.labels
}

/******************************************
  Module config
*******************************************/
module "sanitize_labels" {
  source = "../../../modules/sanitize_labels"
  labels = merge(var.global_labels, local.module_labels)
}

data "terraform_remote_state" "project" {
  backend = "gcs"

  config = {
    bucket = "${var.global_org_name}-tfstate"
    prefix = "${var.environment}/project"
  }
}

# https://github.com/terraform-google-modules/terraform-google-github-actions-runners/tree/master/modules/gh-oidc
module "open_id_connect" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "~> 3.1"

  # required
  project_id  = local.project_id
  pool_id     = "${local.project_id}-oidc-pool"
  provider_id = "${local.project_id}-oidc-provider"

  # optional
  sa_mapping = {} # disable, IAM mapping occurs in the `project` module

  # default
  allowed_audiences = []
  attribute_mapping = {
    "attribute.actor"      = "assertion.actor",
    "attribute.aud"        = "assertion.aud",
    "attribute.repository" = "assertion.repository",
    "google.subject"       = "assertion.sub"
  }
  issuer_uri            = "https://token.actions.githubusercontent.com"
  pool_description      = "Workload Identity Pool for GitHub Actions managed by Terraform"
  pool_display_name     = "${local.project_id}-oidc-pool"
  provider_description  = "Workload Identity Pool Provider for GitHub Actions managed by Terraform"
  provider_display_name = "${local.project_id}-oidc-provider"
}
