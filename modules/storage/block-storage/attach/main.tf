resource "oci_core_volume_attachment" "attach_block_volume" {
  for_each = {
    for vol in var.block_volumes : vol => vol
  }

  #attachment_type = "iscsi" or "paravirtualized" (pv use to truenas)
  attachment_type = "paravirtualized"
  instance_id = element(data.oci_core_instances.list_instances.instances, index(
    data.oci_core_instances.list_instances.instances[*].display_name, var.instance_name
  )).id
  volume_id = element(data.oci_core_volumes.list_volumes.volumes, index(
    data.oci_core_volumes.list_volumes.volumes[*].display_name, each.key
  )).id
  display_name = "${var.instance_name}-${each.key}"

  lifecycle {
    ignore_changes = [
      instance_id,
      volume_id
    ]
  }
}

data "oci_core_instances" "list_instances" {
  compartment_id = element(data.oci_identity_compartments.list_compartments.compartments, index(
    data.oci_identity_compartments.list_compartments.compartments[*].name, var.instance_compartment_name
  )).id
}

data "oci_core_volumes" "list_volumes" {
  compartment_id = element(data.oci_identity_compartments.list_compartments.compartments, index(
    data.oci_identity_compartments.list_compartments.compartments[*].name, var.instance_compartment_name
  )).id
  state = "AVAILABLE"
}

data "oci_identity_compartments" "list_compartments" {
  compartment_id = var.client_compartment_id
}
