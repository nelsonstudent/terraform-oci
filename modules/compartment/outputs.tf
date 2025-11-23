output "client_compartment_id" {
  value       = oci_identity_compartment.client_compartment.id
  description = "ID do compartimento principal do ambiente"
}

output "client_compartment_name" {
  value       = oci_identity_compartment.client_compartment.name
  description = "Nome do compartimento principal do ambiente"
}
