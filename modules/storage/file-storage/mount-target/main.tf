module "file_system" {
  source           = "./file-system"
  common_tags      = var.common_tags
  tag_cost_tracker = var.tag_cost_tracker
  compartment_name = var.compartment_name
  compartment_id   = var.compartment_id
  display_name     = var.file_storage_system.name
}

module "mount_target" {
  depends_on = [module.file_system]

  source           = "./mount-target"
  common_tags      = var.common_tags
  tag_cost_tracker = var.tag_cost_tracker
  compartment_name = var.compartment_name
  compartment_id   = var.compartment_id
  mount_targets    = var.file_storage_system.mount_targets
  vcn_id           = var.vcn_id
}

module "export_set" {
  depends_on     = [module.mount_target]
  source         = "./export-set"
  compartment_id = var.compartment_id
  export_sets    = var.file_storage_system.export_sets
}

module "storage_export" {
  depends_on = [module.export_set]

  source           = "./export"
  compartment_id   = var.compartment_id
  storage_exports  = var.file_storage_system.storage_exports
  file_system_name = var.file_storage_system.name
}
