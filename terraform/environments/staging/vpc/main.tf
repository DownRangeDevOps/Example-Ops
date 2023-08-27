/******************************************
  Terraform backend
*******************************************/
terraform {
  backend "gcs" {
    prefix = "staging/vpc"
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

  # subnets
  subnets_global_properties = {
    subnet_region             = local.region
    subnet_flow_logs          = true
    subnet_flow_logs_interval = "INTERVAL_10_MIN"
    subnet_flow_logs_sampling = 0.5
    subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    stack                     = "IPV4_ONLY"
    role                      = "ACTIVE"
  }

  subnets_properties = {
    public = {
      cidr                   = "10.10.0.0/24"
      description            = "(internet accessible)"
      subnet_purpose         = null
      allow_public_ingress   = true
      allow_public_egress    = true
      allow_internal_ingress = true
      allow_internal_egress  = true
    }
    app = {
      cidr                   = "10.20.0.0/24"
      allow_public_ingress   = false
      allow_public_egress    = false
      allow_internal_ingress = true
      allow_internal_egress  = false
    }
    ops = {
      cidr                   = "10.30.0.0/24"
      allow_public_ingress   = false
      allow_public_egress    = false
      allow_internal_ingress = false
      allow_internal_egress  = true
    }
    services = {
      cidr                   = "10.40.0.0/24"
      allow_public_ingress   = false
      allow_public_egress    = false
      allow_internal_ingress = true
      allow_internal_egress  = true
    }
  }

  subnets = [
    for subnet_name, subnet in local.subnets_properties : merge(
      {
        subnet_name        = subnet_name
        subnet_description = "${var.global_org_name} ${var.environment} ${subnet_name} ${lookup(subnet, "description", "private")} subnet"
        subnet_ip          = "${subnet.cidr}"
        purpose            = "${lookup(subnet, "subnet_purpose", "PRIVATE")}"
      }, local.subnets_global_properties
    )
  ]

  # routes
  routes = [
    {
      name              = "public-egress"
      description       = "${var.global_org_name} ${var.environment} egress route to access the internet via IGW"
      destination_range = "0.0.0.0/0"
      next_hop_internet = true
      priority          = "20000"
    }
  ]

  # firewall rules
  firewall_directions = ["ingress", "egress"]
  firewall_deny_all = [
    for rule_direction in local.firewall_directions : {
      name       = "${var.global_org_name}-${var.environment}-deny-all-${rule_direction}"
      direction  = "${upper(rule_direction)}"
      priority   = "4000"
      ranges     = ["0.0.0.0/0"]
      deny       = [{ protocol = "all" }]
      log_config = { metadata = "INCLUDE_ALL_METADATA" }
    }
  ]

  # public
  firewall_public_ingress = flatten([
    for rule_direction in local.firewall_directions : [
      for subnet_name, subnet in local.subnets_properties : {
        name        = "${var.global_org_name}-${var.environment}-allow-${subnet_name}-subnet-public-${rule_direction}"
        direction   = "${upper(rule_direction)}"
        priority    = "3000"
        ranges      = ["${subnet.cidr}"]
        source_tags = ["${subnet_name}"]
        log_config  = { metadata = "INCLUDE_ALL_METADATA" }
        allow       = [{ protocol = "tcp", ports = ["80", "8080", "443"] }, ]
      } if subnet.allow_public_ingress
    ] if rule_direction == "ingress"
  ])

  firewall_public_egress = flatten([
    for rule_direction in local.firewall_directions : [
      for subnet_name, subnet in local.subnets_properties : {
        name        = "${var.global_org_name}-${var.environment}-allow-${subnet_name}-subnet-public-${rule_direction}"
        direction   = "${upper(rule_direction)}"
        priority    = "3000"
        ranges      = ["0.0.0.0/0"]
        target_tags = ["${subnet_name}"]
        log_config  = { metadata = "INCLUDE_ALL_METADATA" }
        allow = [
          { protocol = "icmp" },
          { protocol = "tcp", ports = ["80", "443"] },
          { protocol = "udp", ports = ["53"] },
        ]
      } if subnet.allow_public_egress
    ] if rule_direction == "egress"
  ])

  # internal
  firewall_internal_ingress = flatten([
    for rule_direction in local.firewall_directions : [
      for subnet_name, subnet in local.subnets_properties : {
        name        = "${var.global_org_name}-${var.environment}-allow-${subnet_name}-subnet-internal-${rule_direction}"
        direction   = "${upper(rule_direction)}"
        priority    = "3000"
        ranges      = ["10.0.0.0/8"]
        target_tags = ["${subnet_name}"]
        log_config  = { metadata = "INCLUDE_ALL_METADATA" }
        allow       = [{ protocol = "all" }]
      } if subnet.allow_internal_ingress
    ] if rule_direction == "ingress"
  ])
  firewall_internal_egress = flatten([
    for rule_direction in local.firewall_directions : [
      for subnet_name, subnet in local.subnets_properties : {
        name        = "${var.global_org_name}-${var.environment}-allow-${subnet_name}-subnet-internal-${rule_direction}"
        direction   = "${upper(rule_direction)}"
        priority    = "3000"
        ranges      = ["10.0.0.0/8"]
        target_tags = ["${subnet_name}"]
        log_config  = { metadata = "INCLUDE_ALL_METADATA" }
        allow       = [{ protocol = "all" }]
      } if subnet.allow_internal_egress
    ] if rule_direction == "egress"
  ])

  firewall_rules = concat(
    local.firewall_deny_all,
    local.firewall_public_ingress,
    local.firewall_public_egress,
    local.firewall_internal_ingress,
    local.firewall_internal_egress,
  )
}

/******************************************
  Module config
*******************************************/
module "sanitize_labels" {
  source = "../../../modules/sanitize_labels"
  labels = merge(var.global_labels, local.module_labels)
}

module "vpc" {
  # https://github.com/terraform-google-modules/terraform-google-network
  source  = "terraform-google-modules/network/google"
  version = "~> 7.2"

  # required
  project_id   = local.project_id
  network_name = "${var.global_org_name}-${var.environment}-vpc"
  subnets      = local.subnets

  # optional
  auto_create_subnetworks                = false
  delete_default_internet_gateway_routes = true
  description                            = "${var.global_org_name} ${var.environment} VPC"
  # firewall_rules                         = local.firewall_rules
  mtu          = 1460
  routes       = local.routes
  routing_mode = "GLOBAL"

  # use defaults
  # secondary_ranges = []
  # shared_vpc_host = false
}
