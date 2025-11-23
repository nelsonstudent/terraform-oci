output "compartment_ids" {
  description = "Map de nomes e IDs dos compartments"
  value       = { for k, v in oci_identity_compartment.this : k => v.id }
}

output "group_ids" {
  description = "Map de nomes e IDs dos grupos"
  value       = { for k, v in oci_identity_group.this : k => v.id }
}

output "user_ids" {
  description = "Map de nomes e IDs dos usuários"
  value       = { for k, v in oci_identity_user.this : k => v.id }
}

output "policy_ids" {
  description = "Map de nomes e IDs das policies"
  value       = { for k, v in oci_identity_policy.this : k => v.id }
}

output "dynamic_group_ids" {
  description = "Map de nomes e IDs dos dynamic groups"
  value       = { for k, v in oci_identity_dynamic_group.this : k => v.id }
}

output "auth_tokens" {
  description = "Auth tokens criados (sensível)"
  value       = { for k, v in oci_identity_auth_token.this : k => v.token }
  sensitive   = true
}

output "customer_secret_keys" {
  description = "Customer secret keys criados (sensível)"
  value = {
    for k, v in oci_identity_customer_secret_key.this : k => {
      id     = v.id
      key    = v.key
      secret = v.key
    }
  }
  sensitive = true
}

output "tag_namespace_ids" {
  description = "Map de nomes e IDs dos tag namespaces"
  value       = { for k, v in oci_identity_tag_namespace.this : k => v.id }
}
