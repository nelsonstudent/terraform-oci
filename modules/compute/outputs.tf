# modules/compute/outputs.tf

output "instance_ids" {
  description = "IDs das instâncias criadas"
  value       = oci_core_instance.this[*].id
}

output "instance_public_ips" {
  description = "IPs públicos das instâncias"
  value       = oci_core_instance.this[*].public_ip
}

output "instance_private_ips" {
  description = "IPs privados das instâncias"
  value       = oci_core_instance.this[*].private_ip
}

output "instance_names" {
  description = "Nomes das instâncias"
  value       = oci_core_instance.this[*].display_name
}

output "boot_volume_ids" {
  description = "IDs dos boot volumes"
  value       = oci_core_instance.this[*].boot_volume_id
}

output "block_volume_ids" {
  description = "IDs dos block volumes adicionais"
  value       = var.create_block_volume ? oci_core_volume.this[*].id : []
}

output "block_volume_attachment_ids" {
  description = "IDs dos attachments de block volumes"
  value       = var.create_block_volume ? oci_core_volume_attachment.this[*].id : []
}
