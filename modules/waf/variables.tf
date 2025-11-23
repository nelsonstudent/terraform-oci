# Váriaveis para conexão com o OCI provider
variable "default_region_account" {}
variable "region" {}
variable "private_key_path" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}

# TagNamespace
variable "tag_cost_tracker" {}

# Compartimento e 
variable "compartment_id" {
  type        = string
  description = "OCID do compartimento onde os recursos WAF serão criados."
}
variable "compartment_name" {
  type        = string
  description = "Nome do compartimento para uso em tags."
}
# Sub compartimentos
variable "sub_compartments" {
  type = list(string)
}

# VCN
variable "vcn" {}

# Tags comuns
variable "common_tags" {
  type = map(string)
}

# Subnets
variable "subnets" {}


# Compute instances
variable "instance_list" {}

# Database System
variable "databases_list" {
  type = list(object({
    compartment             = string
    subnet                  = string
    hostname                = string
    shape                   = string
    ssh_public_keys         = string
    database_edition        = string
    time_zone               = string
    data_storage_size_in_gb = string
    reco_storage_size_in_gb = string
    node_count              = string
    admin_password          = string
    character_set           = string
    db_name                 = string
    db_workload             = string
    ncharacter_set          = string
    db_version              = string
    display_name            = string
    pdb_name                = string
    disk_redundancy         = string
    auto_backup_enabled     = string
    recovery_window_in_days = string
    auto_backup_window      = string
    cpu_core_count          = number
    security_group_names    = list(string)
  }))
}

# Security Groups
variable "security_groups" {
  default = {}
}

# Route Tables
variable "route_tables" {}

# Load Balancer DB
variable "load_balancer_db" {
  default = null
}

# Load Balancer Instance
variable "load_balancers" {
  default = null
}

# Storage - Block Volumes
variable "block_volumes" {
  default = null
}

# Storage - File System
variable "file_storage_system" {
  default = null
}
# VPN - IPSec
variable "vpns" {
  default = null
}

# WAF
variable "waf" {
  type = object({
    name = string
    load_balancer_name = string
    actions = list(object({
      type = string
      name = string
      code = optional(number)
      body = optional(object({
        type = string
        text = string
      }))
      headers = optional(list(object({
        name = string
        value = string
      })))
    }))
    request_access_control = optional(object({
      default_action_name = string
      rules = list(object({
        type = string
        name = string
        action_name = string
        condition = string
        condition_language = string
      }))
    }))
    response_access_control = optional(object({
      rules = list(object({
        type = string
        name = string
        action_name = string
        condition = string
        condition_language = string
      }))
    }))
    request_rate_limiting = optional(object({
      rules = list(object({
        type = string
        name = string
        action_name = string
        condition = string
        condition_language = string
        configurations = object({
          period_in_seconds = number
          requests_limit = number
          action_duration_in_seconds = number
        })
      }))
    }))
    request_protection = optional(object({
      body_inspection_size_limit_exceeded_action_name = string
      body_inspection_size_limit_in_bytes = number
      rules = list(object({
        type = string
        name = string
        action_name = string
        is_body_inspection_enabled = bool
        condition = string
        condition_language = string
        protection_capabilities = list(object({
          key = string
          version = number
        }))
      }))
    }))
  })
  default = null
}

# Fast Connect
variable "fast_connect" {
  default = null
}
# Public IPs
variable "public_ips_names" {
  default = []
}
