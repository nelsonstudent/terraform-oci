# modules/network/variables.tf

variable "compartment_id" {
  description = "ID do compartment onde os recursos serão criados"
  type        = string
}

variable "vcn_name" {
  description = "Nome da VCN"
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "Lista de blocos CIDR para a VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vcn_dns_label" {
  description = "DNS label para a VCN"
  type        = string
  default     = "vcn"
}

variable "create_internet_gateway" {
  description = "Criar Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Criar NAT Gateway"
  type        = bool
  default     = true
}

variable "create_service_gateway" {
  description = "Criar Service Gateway"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "Lista de subnets públicas"
  type = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
  default = []
}

variable "private_subnets" {
  description = "Lista de subnets privadas"
  type = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
  default = []
}

variable "allow_public_ssh" {
  description = "Permitir SSH (porta 22) nas subnets públicas"
  type        = bool
  default     = false
}

variable "allow_public_http" {
  description = "Permitir HTTP (porta 80) nas subnets públicas"
  type        = bool
  default     = true
}

variable "allow_public_https" {
  description = "Permitir HTTPS (porta 443) nas subnets públicas"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags freeform para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Tags definidas para aplicar aos recursos"
  type        = map(string)
  default     = {}
}
