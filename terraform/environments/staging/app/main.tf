/******************************************
  Terraform backend
*******************************************/
terraform {
  backend "gcs" {
    prefix = "staging/app"
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

  bucket_labels = {
    description = "exampleco app static HTML storage"
  }

  sanitized_module_labels = module.sanitize_labels["module_labels"].labels
  sanitized_bucket_labels = module.sanitize_labels["bucket_labels"].labels

  static_assets_bucket_name = "${var.global_org_name}-${var.environment}-app-bucket-static-assets"
  app_domain_name           = var.global_app_domain
  backend_domain_name       = "server.${local.app_domain_name}"
  app_domains               = [local.backend_domain_name, local.app_domain_name]
}

/******************************************
  Storage config
*******************************************/
module "sanitize_labels" {
  source = "../../../modules/sanitize_labels"

  for_each = {
    module_labels = merge(var.global_labels, local.module_labels)
    bucket_labels = merge(var.global_labels, local.bucket_labels)
  }

  labels = each.value
}

module "storage" {
  # https://github.com/terraform-google-modules/terraform-google-cloud-storage
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 4.0"

  # required
  names      = [local.static_assets_bucket_name]
  project_id = local.project_id

  # optional
  bucket_policy_only = { (local.static_assets_bucket_name) = true }
  force_destroy      = { (local.static_assets_bucket_name) = true }
  labels             = local.sanitized_bucket_labels
  location           = local.region
  set_viewer_roles   = true
  website            = { main_page_suffix = "index.html" }

  # bucket access
  bucket_admins   = { (local.static_assets_bucket_name) = "${local.github_sa_iam_email}" }
  bucket_viewers  = { (local.static_assets_bucket_name) = "allUsers" }
  set_admin_roles = true

  cors = [
    {
      origin          = ["*"]
      method          = ["GET"]
      response_header = ["Content-Type", "Access-Control-Allow-Origin"]
      max_age_seconds = 3600
    }
  ]


  # default
  # admins                   = []
  # bucket_admins            = {}
  # bucket_hmac_key_admins   = {}
  # bucket_lifecycle_rules   = {}
  # bucket_storage_admins    = {}
  # creators                 = []
  # custom_placement_config  = {}
  # default_event_based_hold = {}
  # encryption_key_names     = {}
  # folders                  = {}
  # hmac_key_admins          = []
  # hmac_service_accounts    = {}
  # lifecycle_rules          = []
  # logging                  = {}
  # prefix                   = ""
  # public_access_prevention = "inherited"
  # randomize_suffix         = false
  # retention_policy         = {}
  # set_admin_roles          = false
  # set_creator_roles        = false
  # set_hmac_access          = false
  # set_hmac_key_admin_roles = false
  # set_storage_admin_roles  = false
  # set_viewer_roles         = false
  # storage_admins           = []
  # storage_class            = "STNDARD"
  # versioning               = {}
  # viewers                  = []
}
