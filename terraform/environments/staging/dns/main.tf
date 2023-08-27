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

  sanitized_module_labels = module.sanitize_labels["module_labels"].labels
  app_domain_name         = var.global_app_domain
  backend_domain_name     = "server.${local.app_domain_name}"
}

/******************************************
  Cloud DNS config
*******************************************/
module "sanitize_labels" {
  source = "../../../modules/sanitize_labels"

  for_each = {
    module_labels = merge(var.global_labels, local.module_labels)
    bucket_labels = merge(var.global_labels, local.bucket_labels)
  }

  labels = each.value
}

module "dns-public-zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 4.0"

  # required
  domain     = "${var.global_app_domain}."
  name       = var.global_app_domain
  project_id = local.project_id

  # optional
  description   = "${local.project_id}-dns-public-zone"
  force_destroy = true
  labels        = local.sanitized_module_labels
  type          = "public"

  recordsets = [
    {
      name    = ""
      type    = "NS"
      ttl     = 300
      records = ["127.0.0.1"]
    },
    {
      name    = "localhost"
      type    = "A"
      ttl     = 300
      records = ["127.0.0.1"]
    },
  ]

  # default
  # description                        = "Managed by Terraform"
  # dnssec_config                      = any
  # enable_logging                     = false
  # force_destroy                      = false
  # labels                             = {}
  # private_visibility_config_networks = []
  # recordsets                         = []
  # service_namespace_url              = ""
  # target_name_server_addresses       = []
  # target_network                     = ""
  # type                               = "private"
}
