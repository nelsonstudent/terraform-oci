locals {
  module_common_tags = {
    module = "blockvolume"
  }
}

resource "oci_core_volume" "block_volume" {
  compartment_id = element(data.oci_identity_compartments.list_compartments.compartments, index(
    data.oci_identity_compartments.list_compartments.compartments[*].name, var.compartment_name
  )).id
  display_name          = var.display_name
  availability_domain   = data.oci_identity_availability_domains.list_availability_domains.availability_domains[0].name # Usa sempre o primeiro AD
  size_in_gbs           = var.size_in_gbs
  is_auto_tune_enabled  = true
  defined_tags          = { "${var.tag_cost_tracker}" = var.client_compartment_name }
  freeform_tags         = merge(var.common_tags, local.module_common_tags)

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedDate"],
      defined_tags["Oracle-Tags.CreatedOn"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"]
    ]
  }
}

resource "oci_core_volume_backup_policy_assignment" "block_volume_backup_policy_assignment" {
  depends_on = [oci_core_volume.block_volume]
  count      = var.backup_policy_name != "" ? 1 : 0

  asset_id = oci_core_volume.block_volume.id
  policy_id = length(regexall("gold|silver|bronze", var.backup_policy_name)) > 0 ? element(data.oci_core_volume_backup_policies.list_volume_backup_policies.volume_backup_policies, index(
    data.oci_core_volume_backup_policies.list_volume_backup_policies.volume_backup_policies[*].display_name, var.backup_policy_name
  )).id : var.backup_policy_name
}

data "oci_core_volume_backup_policies" "list_volume_backup_policies" {
}

data "oci_identity_availability_domains" "list_availability_domains" {
  compartment_id = var.client_compartment_id
}

data "oci_identity_compartments" "list_compartments" {
  compartment_id = var.client_compartment_id
}
