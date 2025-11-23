# Compartments
resource "oci_identity_compartment" "this" {
  for_each      = { for comp in var.compartments : comp.name => comp }
  compartment_id = var.parent_compartment_id
  description    = each.value.description
  name           = each.value.name
  enable_delete  = each.value.enable_delete
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Groups
resource "oci_identity_group" "this" {
  for_each       = { for group in var.groups : group.name => group }
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Users
resource "oci_identity_user" "this" {
  for_each       = { for user in var.users : user.name => user }
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  email          = each.value.email
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# User Group Memberships
resource "oci_identity_user_group_membership" "this" {
  for_each = {
    for membership in flatten([
      for user in var.users : [
        for group in user.groups : {
          user  = user.name
          group = group
          key   = "${user.name}-${group}"
        }
      ]
    ]) : membership.key => membership
  }
  
  user_id  = oci_identity_user.this[each.value.user].id
  group_id = oci_identity_group.this[each.value.group].id
}

# Policies
resource "oci_identity_policy" "this" {
  for_each       = { for policy in var.policies : policy.name => policy }
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : var.parent_compartment_id
  name           = each.value.name
  description    = each.value.description
  statements     = each.value.statements
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Dynamic Groups
resource "oci_identity_dynamic_group" "this" {
  for_each       = { for dg in var.dynamic_groups : dg.name => dg }
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  matching_rule  = each.value.matching_rule
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# API Keys for Users
resource "oci_identity_api_key" "this" {
  for_each = {
    for api_key in var.api_keys : "${api_key.user_name}-${api_key.key_name}" => api_key
  }
  
  user_id   = oci_identity_user.this[each.value.user_name].id
  key_value = each.value.public_key
}

# Auth Tokens for Users
resource "oci_identity_auth_token" "this" {
  for_each = {
    for token in var.auth_tokens : "${token.user_name}-${token.description}" => token
  }
  
  user_id     = oci_identity_user.this[each.value.user_name].id
  description = each.value.description
}

# Customer Secret Keys (for S3 compatibility)
resource "oci_identity_customer_secret_key" "this" {
  for_each = {
    for key in var.customer_secret_keys : "${key.user_name}-${key.display_name}" => key
  }
  
  user_id      = oci_identity_user.this[each.value.user_name].id
  display_name = each.value.display_name
}

# Network Sources (IP-based restrictions)
resource "oci_identity_network_source" "this" {
  for_each       = { for ns in var.network_sources : ns.name => ns }
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  
  dynamic "virtual_source_list" {
    for_each = each.value.vcn_ids != null ? [1] : []
    content {
      vcn_id    = each.value.vcn_ids[0]
      ip_ranges = each.value.ip_ranges
    }
  }
  
  public_source_list = each.value.vcn_ids == null ? each.value.ip_ranges : []
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Tag Namespaces
resource "oci_identity_tag_namespace" "this" {
  for_each       = { for ns in var.tag_namespaces : ns.name => ns }
  compartment_id = var.parent_compartment_id
  name           = each.value.name
  description    = each.value.description
  is_retired     = each.value.is_retired
  
  freeform_tags = var.tags
}

# Tag Definitions
resource "oci_identity_tag" "this" {
  for_each = {
    for tag in flatten([
      for ns in var.tag_namespaces : [
        for tag_def in ns.tags : {
          namespace = ns.name
          name      = tag_def.name
          desc      = tag_def.description
          key       = "${ns.name}.${tag_def.name}"
        }
      ]
    ]) : tag.key => tag
  }
  
  tag_namespace_id = oci_identity_tag_namespace.this[each.value.namespace].id
  name             = each.value.name
  description      = each.value.desc
}
