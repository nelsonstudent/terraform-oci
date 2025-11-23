locals {
  module_common_tags = {
    module = "filestorage"
  }
}

resource "oci_file_storage_file_system" "file_storage_system" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.list_availability_domains.availability_domains[0].name # Usa sempre o primeiro AD
  display_name        = var.display_name
  defined_tags        = { "${var.tag_cost_tracker}" = var.compartment_name }
  freeform_tags       = merge(var.common_tags, local.module_common_tags)

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"],
      compartment_id,
      availability_domain,
    ]
  }
}

data "oci_identity_availability_domains" "list_availability_domains" {
  compartment_id = var.compartment_id
}
