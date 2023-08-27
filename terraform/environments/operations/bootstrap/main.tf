/******************************************
  Terraform and provider config
*******************************************/
terraform {
  # backend "local" {} # Once bootstrapped, comment this and use the "gcs" backend

  backend "gcs" {
    prefix = "global/bootstrap"
  }
}

/******************************************
  Local variables
*******************************************/
locals {
  module_labels = {
    department = var.ops_label_department
  }

  bucket_labels = {
    description = "Terraform remote state storage for operations infrastructure"
  }

  sanitized_module_labels = module.sanitized_labels["module_labels"].labels
  sanitized_bucket_labels = module.sanitized_labels["bucket_labels"].labels
}

/******************************************
  Module config
*******************************************/
module "sanitized_labels" {
  for_each = {
    module_labels = merge(var.global_labels, local.module_labels)
    bucket_labels = merge(var.global_labels, local.bucket_labels)
  }

  source = "../../../modules/sanitize_labels"
  labels = each.value
}

module "folders" {
  # https://github.com/terraform-google-modules/terraform-google-folders
  source  = "terraform-google-modules/folders/google"
  version = "~> 4.0"

  # required
  parent = var.global_company_folder_id

  # optional
  all_folder_admins = [var.global_group_org_admins]
  per_folder_admins = {} # none
  prefix            = "" # none
  set_roles         = false
  names = [
    "operations",
    "staging",
    "production",
  ]
}

module "bootstrap" {
  # https://github.com/terraform-google-modules/terraform-google-bootstrap
  source     = "terraform-google-modules/bootstrap/google"
  version    = "~> 6.4"
  depends_on = [module.folders]

  # required
  billing_account      = var.global_billing_account
  default_region       = local.region
  group_billing_admins = var.global_group_billing_admins
  group_org_admins     = var.global_group_org_admins
  org_id               = var.global_organization_id
  parent_folder        = var.global_company_folder_id

  # optional
  folder_id               = module.folders.ids.operations
  project_id              = "${var.global_org_name}-${var.ops_project_id}"
  project_labels          = local.sanitized_module_labels
  project_prefix          = "${var.global_org_name}-${var.ops_project_id}"
  random_suffix           = false
  sa_enable_impersonation = true
  state_bucket_name       = "${var.global_org_name}-${var.ops_state_bucket_name}"
  storage_bucket_labels   = merge(local.sanitized_module_labels, local.sanitized_bucket_labels)
  tf_service_account_id   = var.ops_tf_service_account_id
  tf_service_account_name = "${title(local.sanitized_module_labels.organization)} Terraform Account"
  sa_org_iam_permissions = [
    # defaults
    "roles/billing.user",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.organizationViewer",

    # additional
    "roles/artifactregistry.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountActor",
    "roles/iam.serviceAccountCreator",
    "roles/iam.workforcePoolViewer",
    "roles/iam.workloadIdentityUser",
    "roles/run.admin",
    "roles/storage.admin",
  ]

  # use defaults
  # activate_apis                  = []
  # create_terraform_sa            = true
  # encrypt_gcs_bucket_tfstate     = false
  # force_destroy                  = false
  # grant_billing_user             = true
  # key_protection_level           = ""
  # key_rotation_period            = ""
  # kms_prevent_destroy            = true
  # org_admins_org_iam_permissions = []
  # org_project_creators           = []
}
