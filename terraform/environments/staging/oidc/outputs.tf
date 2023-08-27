/*****************************************
  Workload Identity
 *****************************************/
output "pool_name" {
  description = "Pool name"
  value       = module.open_id_connect.pool_name
}

output "provider_name" {
  description = "Provider name"
  value       = module.open_id_connect.provider_name
}
