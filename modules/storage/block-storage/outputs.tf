output "block_volume_id" {
  value = oci_core_volume.block_volume.id
  description = "OCID do volume de bloco criado"
}

output "block_volume_name" {
  value = oci_core_volume.block_volume.display_name
  description = "Nome de exibição do volume de bloco criado"
}

output "block_volume_backup_policy_id" {
  value = var.backup_policy_name != "" ? oci_core_volume_backup_policy_assignment.block_volume_backup_policy_assignment[0].id : ""
  description = "OCID da política de backup do volume de bloco, se uma foi atribuída"
}
