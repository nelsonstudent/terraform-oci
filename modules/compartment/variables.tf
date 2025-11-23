# Region
variable "default_region_account" {
  description = "Definição da Região Default da conta para criar os compartments"
  type        = string
}

# Common TAGS
variable "common_tags" {
  description = "As tags comuns a serem aplicadas aos recursos"
  type        = map(string)
}

# TagNamespace
variable "tag_cost_tracker" {
  description = "O namespace das tags para o rastreamento de custos"
  type        = string
}

# Tenancy
variable "tenancy_ocid" {
  description = "O OCID da tenancy (entidade raiz) da conta"
  type        = string
}

# Compartiments
variable "client_compartment" {
  description = "Compartimentos do cliente"
  type        = map(string)
}
variable "sub_compartments" {
  description = "Compartimentos secundários"
  type        = list(string)
}
