# -----------------------------------------------------------------------------
# Variáveis de Autenticação OCI
# -----------------------------------------------------------------------------
variable "region" {
  description = "Região da OCI para provisionar os recursos."
  type        = string
}

variable "tenancy_ocid" {
  description = "OCID da sua tenancy."
  type        = string
}

variable "user_ocid" {
  description = "OCID do seu usuário."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave de API."
  type        = string
}

variable "private_key_path" {
  description = "Caminho para a chave privada da API."
  type        = string
}

variable "compartment_id" {
  description = "OCID do compartment onde os recursos serão criados."
  type        = string
}

variable "availability_domain" {
  description = "O Availability Domain para criar os recursos (ex: Uocm:SA-SAOPAULO-1-AD-1)."
  type        = string
}

# -----------------------------------------------------------------------------
# Variáveis Gerais do Projeto
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "Nome do projeto, usado como prefixo para os recursos."
  type        = string
  default     = "fullstackapp"
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso às instâncias."
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Tags comuns para aplicar a todos os recursos."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Variáveis de Rede
# -----------------------------------------------------------------------------
variable "vcn_cidr_blocks" {
  description = "Blocos CIDR para a VCN."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnets" {
  description = "Configuração das sub-redes públicas."
  type        = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
}

variable "private_subnets" {
  description = "Configuração das sub-redes privadas."
  type        = list(object({
    name      = string
    cidr      = string
    dns_label = string
  }))
}

# -----------------------------------------------------------------------------
# Variáveis de Compute
# -----------------------------------------------------------------------------
variable "web_instance_count" {
  description = "Número de instâncias para a camada web."
  type        = number
  default     = 2
}

variable "web_instance_shape" {
  description = "Shape das instâncias web."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "web_instance_ocpus" {
  description = "Número de OCPUs para cada instância web."
  type        = number
  default     = 1
}

variable "web_instance_memory" {
  description = "Memória em GB para cada instância web."
  type        = number
  default     = 16
}

variable "app_instance_count" {
  description = "Número de instâncias para a camada de aplicação."
  type        = number
  default     = 2
}

variable "app_instance_shape" {
  description = "Shape das instâncias de aplicação."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "app_instance_ocpus" {
  description = "Número de OCPUs para cada instância de aplicação."
  type        = number
  default     = 2
}

variable "app_instance_memory" {
  description = "Memória em GB para cada instância de aplicação."
  type        = number
  default     = 32
}

# -----------------------------------------------------------------------------
# Variáveis de Load Balancer
# -----------------------------------------------------------------------------
variable "lb_min_bandwidth" {
  description = "Largura de banda mínima para o Load Balancer (Mbps)."
  type        = number
  default     = 10
}

variable "lb_max_bandwidth" {
  description = "Largura de banda máxima para o Load Balancer (Mbps)."
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Variáveis de Banco de Dados
# -----------------------------------------------------------------------------
variable "db_admin_password" {
  description = "Senha para o usuário admin do Autonomous Database."
  type        = string
  sensitive   = true
}
