output "network" {
  value       = module.vpc.network
  description = "The created network"
}

output "subnets" {
  value       = module.vpc.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = module.vpc.network_id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "project_id" {
  value       = module.vpc.project_id
  description = "VPC project id"
}

output "subnets_names" {
  value       = module.vpc.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = module.vpc.subnets_ids
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = module.vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.vpc.subnets_regions
  description = "The region where the subnets will be created"
}

output "subnets_private_access" {
  value       = module.vpc.subnets_private_access
  description = "Whether the subnets will have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = module.vpc.subnets_flow_logs
  description = "Whether the subnets will have VPC flow logs enabled"
}

output "subnets_secondary_ranges" {
  value       = module.vpc.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

output "route_names" {
  value       = module.vpc.route_names
  description = "The route names associated with this VPC"
}
