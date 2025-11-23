# Módulo para Oracle Kubernetes Engine (OKE)

# OKE Cluster
resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  
  # Cluster Type
  cluster_pod_network_options {
    cni_type = var.cni_type  # FLANNEL_OVERLAY, OCI_VCN_IP_NATIVE
  }
  
  # Endpoint Configuration
  endpoint_config {
    is_public_ip_enabled = var.is_public_api_endpoint
    subnet_id            = var.kubernetes_api_endpoint_subnet_id
    nsg_ids              = var.kubernetes_api_endpoint_nsg_ids
  }
  
  # Service LB Subnets
  options {
    service_lb_subnet_ids = var.service_lb_subnet_ids
    
    add_ons {
      is_kubernetes_dashboard_enabled = var.is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false  # Deprecated
    }
    
    admission_controller_options {
      is_pod_security_policy_enabled = var.is_pod_security_policy_enabled
    }
    
    persistent_volume_config {
      freeform_tags = var.pv_tags
      defined_tags  = var.pv_defined_tags
    }
    
    service_lb_config {
      freeform_tags = var.lb_tags
      defined_tags  = var.lb_defined_tags
    }
  }
  
  # Image Policy
  dynamic "image_policy_config" {
    for_each = var.image_policy_enabled ? [1] : []
    content {
      is_policy_enabled = true
      
      dynamic "key_details" {
        for_each = var.image_policy_kms_key_id != null ? [1] : []
        content {
          kms_key_id = var.image_policy_kms_key_id
        }
      }
    }
  }
  
  # Type (BASIC_CLUSTER or ENHANCED_CLUSTER)
  type = var.cluster_type
  
  # KMS Encryption
  kms_key_id = var.kms_key_id
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Node Pool
resource "oci_containerengine_node_pool" "this" {
  for_each       = { for np in var.node_pools : np.name => np }
  cluster_id     = oci_containerengine_cluster.this.id
  compartment_id = var.compartment_id
  name           = each.value.name
  
  kubernetes_version = each.value.kubernetes_version != null ? each.value.kubernetes_version : var.kubernetes_version
  
  # Node Shape
  node_shape = each.value.node_shape
  
  dynamic "node_shape_config" {
    for_each = each.value.node_shape_config != null ? [each.value.node_shape_config] : []
    content {
      ocpus         = node_shape_config.value.ocpus
      memory_in_gbs = node_shape_config.value.memory_in_gbs
    }
  }
  
  # Node Configuration
  node_config_details {
    size = each.value.node_count
    
    dynamic "placement_configs" {
      for_each = each.value.placement_configs
      content {
        availability_domain = placement_configs.value.availability_domain
        subnet_id           = placement_configs.value.subnet_id
        capacity_reservation_id = placement_configs.value.capacity_reservation_id
        fault_domains       = placement_configs.value.fault_domains
      }
    }
    
# Node pool options
is_pv_encryption_in_transit_enabled = each.value.is_pv_encryption_in_transit_enabled

dynamic "node_pool_pod_network_option_details" {
  for_each = each.value.pod_subnet_ids != null ? [1] : []
  content {
    cni_type       = var.cni_type
    pod_subnet_ids = each.value.pod_subnet_ids # Corrigido: lista passada diretamente
  }
}
    
    nsg_ids              = each.value.nsg_ids
    kms_key_id           = each.value.kms_key_id
    freeform_tags        = merge(var.tags, each.value.tags)
    defined_tags         = merge(var.defined_tags, each.value.defined_tags)
  }
  
  # Node Source Details (Image)
  node_source_details {
    source_type = "IMAGE"
    image_id    = each.value.image_id != null ? each.value.image_id : data.oci_containerengine_node_pool_option.this.sources[0].image_id
    boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
  }
  
  # SSH Key
  ssh_public_key = each.value.ssh_public_key != null ? each.value.ssh_public_key : var.ssh_public_key
  
  # Initial Node Labels
  initial_node_labels {
    key   = "pool"
    value = each.value.name
  }
  
  dynamic "initial_node_labels" {
    for_each = each.value.node_labels
    content {
      key   = initial_node_labels.value.key
      value = initial_node_labels.value.value
    }
  }
  
  freeform_tags = merge(var.tags, each.value.tags)
  defined_tags  = merge(var.defined_tags, each.value.defined_tags)
}

# Virtual Node Pool (Serverless nodes)
resource "oci_containerengine_virtual_node_pool" "this" {
  for_each       = { for vnp in var.virtual_node_pools : vnp.name => vnp }
  cluster_id     = oci_containerengine_cluster.this.id
  compartment_id = var.compartment_id
  display_name   = each.value.name
  
  dynamic "placement_configurations" {
    for_each = each.value.placement_configs
    content {
      availability_domain = placement_configurations.value.availability_domain
      subnet_id           = placement_configurations.value.subnet_id
      fault_domain        = placement_configurations.value.fault_domains
    }
  }
  
  pod_configuration {
    subnet_id = each.value.pod_subnet_id
    shape     = each.value.pod_shape
    
    dynamic "shape_config" {
      for_each = each.value.pod_shape_config != null ? [each.value.pod_shape_config] : []
      content {
        ocpus         = shape_config.value.ocpus
        memory_in_gbs = shape_config.value.memory_in_gbs
      }
    }
    
    nsg_ids = each.value.nsg_ids
  }
  
  size = each.value.size
  
  dynamic "initial_virtual_node_labels" {
    for_each = each.value.node_labels
    content {
      key   = initial_virtual_node_labels.value.key
      value = initial_virtual_node_labels.value.value
    }
  }
  
  dynamic "taints" {
    for_each = each.value.taints
    content {
      key    = taints.value.key
      value  = taints.value.value
      effect = taints.value.effect
    }
  }
  
  freeform_tags = merge(var.tags, each.value.tags)
  defined_tags  = merge(var.defined_tags, each.value.defined_tags)
}

# Data Sources
data "oci_containerengine_cluster_option" "this" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "this" {
  node_pool_option_id = "all"
}

data "oci_containerengine_cluster_kube_config" "this" {
  cluster_id = oci_containerengine_cluster.this.id
  
  depends_on = [oci_containerengine_cluster.this]
}
