/******************************************
  Required variables
*******************************************/
# None

/******************************************
  Optional variables
*******************************************/
variable "ops_label_department" {
  description = "The department title for this project."
  type        = string

  default = "operations"
}

variable "ops_project_id" {
  description = "The project ID for this module."
  type        = string

  default = "operations" # will be prefixed with `${var.global_org_name}-`
}

variable "environment" {
  description = "The name for this enviornment (string)."
  type        = string

  default = "all"
}

variable "environment_region" {
  description = "The region for this module."
  type        = string

  default = "" # defaults to global_default_region if empty
}

variable "ops_tf_service_account_id" {
  description = "The name of the service account used by Terraform."
  type        = string

  default = "ops-terraform"
}

variable "ops_state_bucket_name" {
  description = "The name of the bucket that Terraform will store remote state for this module within."
  type        = string

  default = "tfstate" # will be prefixed with `${var.global_org_name}-`
}
