/*****************************************
  Required variables
 *****************************************/
# None

/*****************************************
  Optional variables
 *****************************************/
variable "environment" {
  description = "The name for this enviornment (string)."
  type        = string

  default = "staging"
}

variable "environment_region" {
  description = "The region for this module (string)."
  type        = string

  default = "" # local.region defaults to global_default_region if empty
}

variable "staging_label_department" {
  description = "The department title for this project (string)."
  type        = string

  default = "operations"
}

variable "staging_folder_id" {
  description = "The folder ID for this environment (string)."
  type        = string

  default = "41649788809"
}

variable "staging_tf_service_account_id" {
  description = "The name of the service account used by Terraform (string)."
  type        = string

  default = "ops-terraform"
}

variable "staging_state_bucket_name" {
  description = "The name of the bucket that Terraform will store remote state for this module within (string)."
  type        = string

  default = "tfstate" # will be prefixed with "${var.global_org_name}-"
}
