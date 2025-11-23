variable "compartment_id" {
  description = "ID do compartment"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster OKE"
  type        = string
}

variable "vcn_id" {
  description = "ID da VCN"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "v1.28.2"
}

variable "cni_type" {
  description = "Tipo de CNI (FLANNEL_OVERLAY, OCI_VCN_IP_NATIVE)"
  type        = string
  default     = "FLANNEL_OVERLAY"
}

variable "cluster_type" {
  description = "Tipo do cluster (BASIC_CLUSTER, ENHANCED_CLUSTER)"
  type        = string
  default     = "ENHANCED_CLUSTER"
}

# API Endpoint
variable "is_public_api_endpoint" {
  description = "API endpoint é público"
  type        = bool
  default     = true
}

variable "kubernetes_api_endpoint_subnet_id" {
  description = "Subnet ID para API endpoint"
  type        = string
}

variable "kubernetes_api_endpoint_nsg_ids" {
  description = "NSG IDs para API endpoint"
  type        = list(string)
  default     = []
}

# Service Load Balancers
variable "service_lb_subnet_ids" {
  description = "Subnet IDs para service load balancers"
  type        = list(string)
}

# Cluster Options
variable "is_kubernetes_dashboard_enabled" {
  description = "Habilitar Kubernetes Dashboard"
  type        = bool
  default     = false
}

variable "is_pod_security_policy_enabled" {
  description = "Habilitar Pod Security Policy"
  type        = bool
  default     = false
}

# Image Policy
variable "image_policy_enabled" {
  description = "Habilitar image policy"
  type        = bool
  default     = false
}

variable "image_policy_kms_key_id" {
  description = "KMS key ID para image policy"
  type        = string
  default     = null
}

# Encryption
variable "kms_key_id" {
  description = "KMS key ID para criptografia do cluster"
  type        = string
  default     = null
}

# SSH Key
variable "ssh_public_key" {
  description = "Chave SSH pública para os nodes"
  type        = string
  default     = null
}

# Node Pools
variable "node_pools" {
  description = "Configuração dos node pools"
  type = list(object({
    name                                = string
    node_shape                          = string
    node_count                          = number
    kubernetes_version                  = string
    boot_volume_size_in_gbs            = number
    image_id                            = string
    ssh_public_key                      = string
    is_pv_encryption_in_transit_enabled = bool
    kms_key_id                          = string
    nsg_ids                             = list(string)
    pod_subnet_ids                      = list(string)
    node_shape_config = object({
      ocpus         = number
      memory_in_gbs = number
    })
    placement_configs = list(object({
      availability_domain     = string
      subnet_id               = string
      capacity_reservation_id = string
      fault_domains           = list(string)
    }))
    node_labels = list(object({
      key   = string
      value = string
    }))
    tags         = map(string)
    defined_tags = map(string)
  }))
  default = []
}

# Virtual Node Pools
variable "virtual_node_pools" {
  description = "Configuração dos virtual node pools (serverless)"
  type = list(object({
    name           = string
    size           = number
    pod_subnet_id  = string
    pod_shape      = string
    nsg_ids        = list(string)
    pod_shape_config = object({
      ocpus         = number
      memory_in_gbs = number
    })
    placement_configs = list(object({
      availability_domain = string
      subnet_id           = string
      fault_domains       = list(string)
    }))
    node_labels = list(object({
      key   = string
      value = string
    }))
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags         = map(string)
    defined_tags = map(string)
  }))
  default = []
}

# Tags for resources created by cluster
variable "pv_tags" {
  description = "Tags para Persistent Volumes"
  type        = map(string)
  default     = {}
}

variable "pv_defined_tags" {
  description = "Defined tags para Persistent Volumes"
  type        = map(string)
  default     = {}
}

variable "lb_tags" {
  description = "Tags para Load Balancers"
  type        = map(string)
  default     = {}
}

variable "lb_defined_tags" {
  description = "Defined tags para Load Balancers"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags freeform"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Tags definidas"
  type        = map(string)
  default     = {}
}
