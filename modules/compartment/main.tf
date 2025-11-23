# Reconfigurando a região, pois, os compartimentos só podem ser criados na região home da conta OCI
provider "oci" {
  region = var.default_region_account
  #ignore_defined_tags = [
  #  "Oracle-Tags.CreatedBy"
  #]
}

variable "module_common_tags" {
  type = map(string)
  default = {
    module = "compartment"
  }
}

resource "oci_identity_compartment" "client_compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Compartimento administrativo"
  name           = var.client_compartment.name
  defined_tags   = { "${var.tag_cost_tracker}" = var.client_compartment.name }
  freeform_tags  = merge(var.common_tags, var.module_common_tags)

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedDate"],
      defined_tags["Oracle-Tags.CreatedOn"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"]
    ]
  }
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "oci_identity_compartment" "client_subcompartments" {
  count = length(var.sub_compartments)

  compartment_id = oci_identity_compartment.client_compartment.id
  description    = "Sub compartimentos administrativos"
  name           = element(var.sub_compartments, count.index)

  defined_tags  = { "${var.tag_cost_tracker}" = var.client_compartment.name }
  freeform_tags = merge(var.common_tags, var.module_common_tags)

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedDate"],
      defined_tags["Oracle-Tags.CreatedOn"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"]
    ]
  }
  provisioner "local-exec" {
    command = "sleep 20"
  }
}
