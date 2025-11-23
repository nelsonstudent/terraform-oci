variable "tenancy_ocid" {
  description = "OCID do tenancy"
  type        = string
}

variable "parent_compartment_id" {
  description = "OCID do compartment pai"
  type        = string
}

variable "compartments" {
  description = "Lista de compartments a criar"
  type = list(object({
    name          = string
    description   = string
    enable_delete = bool
  }))
  default = []
}

variable "groups" {
  description = "Lista de grupos a criar"
  type = list(object({
    name        = string
    description = string
  }))
  default = []
}

variable "users" {
  description = "Lista de usuários a criar"
  type = list(object({
    name        = string
    description = string
    email       = string
    groups      = list(string)
  }))
  default = []
}

variable "policies" {
  description = "Lista de policies a criar"
  type = list(object({
    name           = string
    description    = string
    compartment_id = string
    statements     = list(string)
  }))
  default = []
}

variable "dynamic_groups" {
  description = "Lista de dynamic groups a criar"
  type = list(object({
    name          = string
    description   = string
    matching_rule = string
  }))
  default = []
}

variable "api_keys" {
  description = "API keys para usuários"
  type = list(object({
    user_name  = string
    key_name   = string
    public_key = string
  }))
  default = []
}

variable "auth_tokens" {
  description = "Auth tokens para usuários"
  type = list(object({
    user_name   = string
    description = string
  }))
  default = []
  sensitive = true
}

variable "customer_secret_keys" {
  description = "Customer secret keys (S3 compatibility)"
  type = list(object({
    user_name    = string
    display_name = string
  }))
  default = []
  sensitive = true
}

variable "network_sources" {
  description = "Network sources para restrições de IP"
  type = list(object({
    name        = string
    description = string
    ip_ranges   = list(string)
    vcn_ids     = list(string)
  }))
  default = []
}

variable "tag_namespaces" {
  description = "Tag namespaces e suas tags"
  type = list(object({
    name        = string
    description = string
    is_retired  = bool
    tags = list(object({
      name        = string
      description = string
    }))
  }))
  default = []
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
