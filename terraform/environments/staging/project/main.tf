/******************************************
  Terraform backend
*******************************************/
terraform {
  backend "gcs" {
    prefix = "staging/project"
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

module "project-factory" {
  # https://github.com/terraform-google-modules/terraform-google-project-factory
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  # required
  billing_account = var.global_billing_account
  name            = "${var.global_org_name}-${var.environment}"
  org_id          = var.global_organization_id

  # optional
  create_project_sa = false
  folder_id         = var.environment_folder_id
  labels            = local.sanitized_module_labels
  project_id        = local.project_id

  # use defaults
  # activate_api_identities                 = []
  # activate_apis                           = "compute.googleapis.com"
  # auto_create_network                     = false
  # bucket_force_destroy                    = false
  # bucket_labels                           = {}
  # bucket_location                         = "US"
  # bucket_name                             = ""
  # bucket_pap                              = "inherited"
  # bucket_project                          = ""
  # bucket_ula                              = true
  # bucket_versioning                       = false
  # budget_alert_pubsub_topic               = null
  # budget_alert_spend_basis                = "CURRENT_SPEND"
  # budget_alert_spent_percents             = [0.5, 0.7, 1]
  # budget_amount                           = null
  # budget_calendar_period                  = null
  # budget_custom_period_end_date           = null
  # budget_custom_period_start_date         = null
  # budget_display_name                     = string
  # budget_labels                           = {}
  # budget_monitoring_notification_channels = []
  # consumer_quotas                         = []
  # default_network_tier                    = ""
  # default_service_account                 = "disable"
  # disable_dependent_services              = true
  # disable_services_on_destroy             = true
  # domain                                  = ""
  # enable_shared_vpc_host_project          = false
  # essential_contacts                      = {}
  # grant_network_role                      = true
  # grant_services_security_admin_role      = false
  # group_name                              = ""
  # group_role                              = "roles/editor"
  # language_tag                            = "en-US"
  # lien                                    = false
  # project_sa_name                         = ""
  # random_project_id                       = false
  # random_project_id_length                = null
  # sa_role                                 = ""
  # shared_vpc_subnets                      = []
  # svpc_host_project_id                    = ""
  # usage_bucket_name                       = ""
  # usage_bucket_prefix                     = ""
  # vpc_service_control_attach_enabled      = false
  # vpc_service_control_perimeter_name      = null
  # vpc_service_control_sleep_duration      = "5s"
}
