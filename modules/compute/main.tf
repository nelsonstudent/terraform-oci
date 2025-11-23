# Módulo para criar Compute Instances (VMs e Bare Metal)

# Data source para obter imagens disponíveis
data "oci_core_images" "this" {
  compartment_id           = var.compartment_id
  operating_system         = var.instance_os
  operating_system_version = var.instance_os_version
  shape                    = var.instance_shape
  
  filter {
    name   = "display_name"
    values = [var.image_name_filter]
    regex  = true
  }
}

# Compute Instance
resource "oci_core_instance" "this" {
  count               = var.instance_count
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.instance_count > 1 ? "${var.instance_name}-${count.index + 1}" : var.instance_name
  shape               = var.instance_shape
  
  # Shape config para Flex shapes
  dynamic "shape_config" {
    for_each = var.instance_shape_config_ocpus != null ? [1] : []
    content {
      ocpus         = var.instance_shape_config_ocpus
      memory_in_gbs = var.instance_shape_config_memory_in_gbs
    }
  }
  
  # Source Details (Boot Volume)
  source_details {
    source_type             = "image"
    source_id               = var.source_image_id != null ? var.source_image_id : data.oci_core_images.this.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }
  
  # Network
  create_vnic_details {
    subnet_id              = var.subnet_id
    display_name           = var.instance_count > 1 ? "${var.instance_name}-vnic-${count.index + 1}" : "${var.instance_name}-vnic"
    assign_public_ip       = var.assign_public_ip
    hostname_label         = var.instance_count > 1 ? "${var.hostname_label}${count.index + 1}" : var.hostname_label
    private_ip             = var.private_ips != null && length(var.private_ips) > count.index ? var.private_ips[count.index] : null
    nsg_ids                = var.nsg_ids
    skip_source_dest_check = var.skip_source_dest_check
  }
  
  # Metadata
  metadata = merge(
    {
      ssh_authorized_keys = var.ssh_public_key
    },
    var.user_data != null ? {
      user_data = base64encode(var.user_data)
    } : {},
    var.custom_metadata
  )
  
  # Agent Config
  agent_config {
    are_all_plugins_disabled = var.disable_all_plugins
    is_management_disabled   = var.disable_management
    is_monitoring_disabled   = var.disable_monitoring
    
    dynamic "plugins_config" {
      for_each = var.enabled_plugins
      content {
        name          = plugins_config.value.name
        desired_state = plugins_config.value.desired_state
      }
    }
  }
  
  # Availability Config
  availability_config {
    is_live_migration_preferred = var.is_live_migration_preferred
    recovery_action              = var.recovery_action
  }
  
  # Options
  is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit
  
  freeform_tags = merge(
    var.tags,
    {
      Name = var.instance_count > 1 ? "${var.instance_name}-${count.index + 1}" : var.instance_name
    }
  )
  defined_tags = var.defined_tags
  
  preserve_boot_volume = var.preserve_boot_volume
  
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
    ]
  }
}

# Block Volume
resource "oci_core_volume" "this" {
  count               = var.create_block_volume ? var.instance_count : 0
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.instance_count > 1 ? "${var.instance_name}-volume-${count.index + 1}" : "${var.instance_name}-volume"
  size_in_gbs         = var.block_volume_size_in_gbs
  vpus_per_gb         = var.block_volume_vpus_per_gb
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Block Volume Attachment
resource "oci_core_volume_attachment" "this" {
  count           = var.create_block_volume ? var.instance_count : 0
  attachment_type = var.block_volume_attachment_type
  instance_id     = oci_core_instance.this[count.index].id
  volume_id       = oci_core_volume.this[count.index].id
  display_name    = var.instance_count > 1 ? "${var.instance_name}-attachment-${count.index + 1}" : "${var.instance_name}-attachment"
  device          = var.block_volume_device
  is_read_only    = var.block_volume_read_only
  is_shareable    = var.block_volume_shareable
}
