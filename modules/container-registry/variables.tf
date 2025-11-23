variable "compartment_id" {
  description = "ID do compartment"
  type        = string
}

variable "repositories" {
  description = "Lista de repositórios de container a criar"
  type = list(object({
    name           = string
    is_public      = bool
    is_immutable   = bool
    readme_content = string
    readme_format  = string
  }))
  default = []
}

variable "generic_repositories" {
  description = "Repositórios genéricos (não apenas containers)"
  type = list(object({
    name            = string
    is_immutable    = bool
    repository_type = string
    description     = string
  }))
  default = []
}

variable "image_signatures" {
  description = "Assinaturas de imagens"
  type = list(object({
    repository_name    = string
    image_id           = string
    image_digest       = string
    kms_key_id         = string
    kms_key_version_id = string
    message            = string
    signature          = string
    signing_algorithm  = string
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
