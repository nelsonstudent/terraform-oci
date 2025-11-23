# OCI Provider variables
variable "region" {
  description = "Região OCI"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCID do tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da API key"
  type        = string
}

variable "private_key_path" {
  description = "Caminho para a chave privada"
  type        = string
}

variable "compartment_id" {
  description = "OCID do compartment"
  type        = string
}

# Cliente variables
variable "cliente_name" {
  description = "Nome do cliente (usado como prefixo)"
  type        = string
}

# Network variables
variable "vcn_cidr_blocks" {
  description = "Blocos CIDR da VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vcn_dns_label" {
  description = "DNS label da VCN"
  type        = string
  default     = "vcn"
}

variable "public_subnets" {
  description = "Subnets públicas"
  type = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
  default = [
    {
      name      = "public-subnet-1"
      cidr      = "10.0.1.0/24"
      dns_label = "public1"
    },
    {
      name      = "public-subnet-2"
      cidr      = "10.0.2.0/24"
      dns_label = "public2"
    }
  ]
}

variable "private_subnets" {
  description = "Subnets privadas"
  type = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
  default = [
    {
      name      = "private-subnet-1"
      cidr      = "10.0.10.0/24"
      dns_label = "private1"
    },
    {
      name      = "private-subnet-2"
      cidr      = "10.0.11.0/24"
      dns_label = "private2"
    }
  ]
}

variable "allow_public_ssh" {
  description = "Permitir SSH público"
  type        = bool
  default     = false
}

# Web Server variables
variable "web_instance_count" {
  description = "Número de instâncias web"
  type        = number
  default     = 2
}

variable "web_instance_shape" {
  description = "Shape das instâncias web"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "web_instance_ocpus" {
  description = "OCPUs para instâncias web"
  type        = number
  default     = 1
}

variable "web_instance_memory" {
  description = "Memória em GB para instâncias web"
  type        = number
  default     = 16
}

variable "web_boot_volume_size" {
  description = "Tamanho do boot volume web em GB"
  type        = number
  default     = 50
}

variable "web_user_data" {
  description = "Script cloud-init para web servers"
  type        = string
  default     = null
}

# App Server variables
variable "app_instance_count" {
  description = "Número de instâncias app"
  type        = number
  default     = 2
}

variable "app_instance_shape" {
  description = "Shape das instâncias app"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "app_instance_ocpus" {
  description = "OCPUs para instâncias app"
  type        = number
  default     = 2
}

variable "app_instance_memory" {
  description = "Memória em GB para instâncias app"
  type        = number
  default     = 32
}

variable "app_boot_volume_size" {
  description = "Tamanho do boot volume app em GB"
  type        = number
  default     = 100
}

variable "app_data_volume_size" {
  description = "Tamanho do volume de dados app em GB"
  type        = number
  default     = 200
}

variable "app_user_data" {
  description = "Script cloud-init para app servers"
  type        = string
  default     = null
}

# Load Balancer variables
variable "lb_min_bandwidth" {
  description = "Bandwidth mínima do LB em Mbps"
  type        = number
  default     = 10
}

variable "lb_max_bandwidth" {
  description = "Bandwidth máxima do LB em Mbps"
  type        = number
  default     = 100
}

# SSH Key
variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}

# Tags
variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}
