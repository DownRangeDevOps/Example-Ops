/*****************************************
  Global organization variables
 *****************************************/
# Set in .envrc
variable "global_org_domain" {
  description = "The organization domain name (string)."
  type        = string
}

variable "global_app_domain" {
  description = "The organization domain name (string)."
  type        = string
}

# Set with defaults
variable "global_organization_id" {
  description = "The organization ID for this project (string)."
  type        = string

  default = "598768499721"
}

variable "global_billing_account" {
  description = "The billing account ID for this project (string)."
  type        = string

  default = "0165DB-BBF936-6FE434"
}

variable "global_default_region" {
  description = "The default region for project module (string)."
  type        = string

  default = "us-west1"
}

variable "global_company_folder_id" {
  description = "The root folder for this project or companies GCP assets (string)."
  type        = string

  default = "folders/206844397186"
}

variable "global_org_name" {
  description = "The prefix to use in all naming (string)."
  type        = string

  default = "exampleco"
}

variable "global_group_org_admins" {
  description = "The group email address for organization admins (string)."
  type        = string

  default = "gcp-org-admins@downtownsb.com"
}

variable "global_group_billing_admins" {
  description = "The group email address for organization billing admins (string)."
  type        = string

  default = "gcp-billing-admins@downtownsb.com"
}

variable "global_labels" {
  description = "A key/value list of labels to apply to all resources (map(string))."
  type        = map(string)

  default = {
    organization = "exampleco"
  }
}

variable "global_kernal_type" {
  description = "The kernal type of the system that is running Terraform (string)"
  type        = string

  default = "darwin"
}
