/*****************************************
  Service accounts
 *****************************************/
output "service_accounts" {
  description = "Service account resources list."
  value       = [for service_accounts in module.service_accounts : service_accounts.service_account]
}

output "sa_emails" {
  description = "Service account emails list."
  value       = [for service_accounts in module.service_accounts : service_accounts.email]
}

output "sa_iam_emails" {
  description = "IAM-format service account emails list."
  value       = [for service_accounts in module.service_accounts : service_accounts.iam_email]
}

output "sa_keys" {
  description = "Service account keys list."
  sensitive   = true
  value       = [for service_accounts in module.service_accounts : service_accounts.key]
}

output "sa_service_accounts_map" {
  description = "Service account resources by name."
  value       = merge([for service_accounts in module.service_accounts : service_accounts.service_accounts_map]...)
}

output "sa_emails_map" {
  description = "Service account emails by name."
  value       = merge([for service_accounts in module.service_accounts : service_accounts.emails]...)
}

output "sa_iam_emails_map" {
  description = "IAM-format service account emails by name."
  value       = merge([for service_account in module.service_accounts : service_account.iam_emails]...)
}

output "sa_keys_map" {
  description = "Service account keys by name."
  sensitive   = true
  value       = [for service_accounts in module.service_accounts : service_accounts.keys]
}
