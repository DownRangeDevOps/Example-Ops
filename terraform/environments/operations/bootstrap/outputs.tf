/******************************************
  Bootstrap
*******************************************/
# Project
output "seed_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.bootstrap.seed_project_id
}

# Service Account
output "terraform_sa_email" {
  description = "Email for privileged service account for Terraform."
  value       = module.bootstrap.terraform_sa_email
}

output "terraform_sa_name" {
  description = "Fully qualified name for privileged service account for Terraform."
  value       = module.bootstrap.terraform_sa_name
}

# GCS Terraform State Bucket
output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for foundations pipelines in seed project."
  value       = module.bootstrap.gcs_bucket_tfstate
}


/******************************************
  Folders
******************************************/
output "folder" {
  description = "Folder resource (for single use)."
  value       = module.folders.folder
}

output "folder_id" {
  description = "Folder id (for single use)."
  value       = module.folders.id
}

output "folder_name" {
  description = "Folder name (for single use)."
  value       = module.folders.name
}

output "folders" {
  description = "Folder resources as list."
  value       = module.folders.folders
}

output "folders_map" {
  description = "Folder resources by name."
  value       = module.folders.folders_map
}

output "folder_ids" {
  description = "Folder ids."
  value       = module.folders.ids
}

output "folder_names" {
  description = "Folder names."
  value       = module.folders.names
}

output "folder_ids_list" {
  description = "List of folder ids."
  value       = module.folders.ids_list
}

output "folder_names_list" {
  description = "List of folder names."
  value       = module.folders.names_list
}

output "per_folder_admins" {
  description = "IAM-style members per folder who will get extended permissions."
  value       = module.folders.per_folder_admins
}
