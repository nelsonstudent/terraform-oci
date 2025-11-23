locals {
  module_common_tags = {
    module = "filestorage"
  }
}

resource "oci_file_storage_export" "file_storage_export" {
  for_each = {
    for storage_export in var.storage_exports : storage_export.export_set_name => storage_export
  }

  export_set_id = element(data.oci_file_storage_export_sets.list_export_sets.export_sets, index(
    data.oci_file_storage_export_sets.list_export_sets.export_sets[*].display_name, each.value.export_set_name
  )).id
  file_system_id = element(data.oci_file_storage_file_systems.list_file_systems.file_systems, index(
    data.oci_file_storage_file_systems.list_file_systems.file_systems[*].display_name, var.file_system_name
  )).id
  path = each.value.path

  export_options {
    source                         = each.value.export_options.source
    access                         = each.value.export_options.access
    identity_squash                = each.value.export_options.identity_squash
    anonymous_uid                  = each.value.export_options.anonymous_uid
    anonymous_gid                  = each.value.export_options.anonymous_gid
    require_privileged_source_port = each.value.export_options.require_privileged_source_port
  }
  lifecycle {
    ignore_changes = [
      export_set_id,
      file_system_id
    ]
  }
}

data "oci_file_storage_export_sets" "list_export_sets" {
  availability_domain = "UyAg:SA-SAOPAULO-1-AD-1"
  compartment_id      = var.compartment_id
}

data "oci_file_storage_file_systems" "list_file_systems" {
  availability_domain = "UyAg:SA-SAOPAULO-1-AD-1"
  compartment_id      = var.compartment_id
}
