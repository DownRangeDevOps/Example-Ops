/*****************************************
  Load balancer
 *****************************************/
output "lb_http_backend_services" {
  description = "The backend service resources."
  value       = module.lb_http.backend_services
  sensitive   = true // can contain sensitive iap_config
}

output "lb_http_external_ip" {
  description = "The external IPv4 assigned to the global fowarding rule."
  value       = module.lb_http.external_ip
}

output "lb_http_external_ipv6_address" {
  description = "The external IPv6 assigned to the global fowarding rule."
  value       = module.lb_http.external_ipv6_address
}

output "lb_http_ipv6_enabled" {
  description = "Whether IPv6 configuration is enabled on this load-balancer"
  value       = module.lb_http.ipv6_enabled
}

output "lb_http_http_proxy" {
  description = "The HTTP proxy used by this module."
  value       = module.lb_http.http_proxy
}

output "lb_http_https_proxy" {
  description = "The HTTPS proxy used by this module."
  value       = module.lb_http.https_proxy
}

output "lb_http_url_map" {
  description = "The default URL map used by this module."
  value       = module.lb_http.url_map
}

/*****************************************
  Artifact Registry
 *****************************************/
output "artifact_registry_repository" {
  value = google_artifact_registry_repository.default.id
}

/*****************************************
  Google Cloud Run
 *****************************************/
output "gcr_service_name" {
  value       = module.cloud_run.service_name
  description = "Name of the created service"
}

output "gcr_revision" {
  value       = module.cloud_run.revision
  description = "Deployed revision for the service"
}

output "gcr_service_url" {
  value       = module.cloud_run.service_url
  description = "The URL on which the deployed service is available"
}

output "gcr_project_id" {
  value       = module.cloud_run.project_id
  description = "Google Cloud project in which the service was created"
}

output "gcr_location" {
  value       = module.cloud_run.location
  description = "Location in which the Cloud Run service was created"
}

output "gcr_service_id" {
  value       = module.cloud_run.service_id
  description = "Unique Identifier for the created service"
}

output "gcr_service_status" {
  value       = module.cloud_run.service_status
  description = "Status of the created service"
}

output "gcr_domain_map_id" {
  value       = module.cloud_run.domain_map_id
  description = "Unique Identifier for the created domain map"
}

output "gcr_domain_map_status" {
  value       = module.cloud_run.domain_map_status
  description = "Status of Domain mapping"
}

output "gcr_verified_domain_name" {
  value       = module.cloud_run.verified_domain_name
  description = "List of Custom Domain Name"
}

/*****************************************
  Storage
 *****************************************/
output "bucket" {
  description = "Bucket resource (for single use)."
  value       = module.storage.bucket
}

output "bucket_name" {
  description = "Bucket name (for single use)."
  value       = module.storage.name
}

output "bucket_url" {
  description = "Bucket URL (for single use)."
  value       = module.storage.url
}

output "bucket_buckets" {
  description = "Bucket resources as list."
  value       = module.storage.buckets
}

output "bucket_buckets_map" {
  description = "Bucket resources by name."
  value       = module.storage.buckets_map
}

output "bucket_names" {
  description = "Bucket names."
  value       = module.storage.names
}

output "bucket_urls" {
  description = "Bucket URLs."
  value       = module.storage.urls
}

output "bucket_names_list" {
  description = "List of bucket names."
  value       = module.storage.names_list
}

output "bucket_urls_list" {
  description = "List of bucket URLs."
  value       = module.storage.urls_list
}

output "bucket_hmac_keys" {
  description = "List of HMAC keys."
  value       = module.storage.hmac_keys
  sensitive   = true
}
