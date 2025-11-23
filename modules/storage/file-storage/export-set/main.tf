resource "oci_file_storage_export_set" "file_storage_export_set" {
  for_each = {
    for export_set in var.export_sets : export_set.display_name => export_set
  }

  mount_target_id = element(data.oci_file_storage_mount_targets.list_mount_targets.mount_targets, index(
    data.oci_file_storage_mount_targets.list_mount_targets.mount_targets[*].display_name, each.value.mount_target_name
  )).id
  display_name      = each.value.display_name
  max_fs_stat_bytes = each.value.max_fs_stat_bytes
  max_fs_stat_files = each.value.max_fs_stat_bytes

  lifecycle {
    ignore_changes = [
      mount_target_id
    ]
  }
}

data "oci_file_storage_mount_targets" "list_mount_targets" {
  availability_domain = "UyAg:SA-SAOPAULO-1-AD-1"
  compartment_id      = var.compartment_id
}
