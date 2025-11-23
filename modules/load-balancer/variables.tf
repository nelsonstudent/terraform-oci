# modules/load-balancer/variables.tf

variable "compartment_id" {
  description = "ID do compartment"
  type        = string
}

variable "lb_name" {
  description = "Nome do Load Balancer"
  type        = string
}

variable "lb_shape" {
  description = "Shape do Load Balancer (100Mbps, 400Mbps, 8000Mbps, flexible)"
  type        = string
  default     = "flexible"
}

variable "lb_min_bandwidth_mbps" {
  description = "Bandwidth mínima em Mbps para shape flexible"
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Bandwidth máxima em Mbps para shape flexible"
  type        = number
  default     = 100
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets onde o LB será criado"
  type        = list(string)
}

variable "is_private" {
  description = "Se o Load Balancer é privado"
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "Lista de IDs de Network Security Groups"
  type        = list(string)
  default     = []
}

variable "reserved_ip_id" {
  description = "ID de IP reservado para usar no Load Balancer"
  type        = string
  default     = null
}

variable "backend_sets" {
  description = "Configuração dos backend sets"
  type = list(object({
    name   = string
    policy = string
    health_checker = object({
      protocol            = string
      port                = number
      url_path            = string
      return_code         = number
      interval_ms         = number
      timeout_in_millis   = number
      retries             = number
      response_body_regex = string
    })
    session_persistence_cookie_name        = string
    session_persistence_disable_fallback   = bool
    ssl_configuration = object({
      certificate_name        = string
      verify_depth            = number
      verify_peer_certificate = bool
    })
    backends = list(object({
      ip_address = string
      port       = number
      backup     = bool
      drain      = bool
      offline    = bool
      weight     = number
    }))
  }))
  default = []
}

variable "listeners" {
  description = "Configuração dos listeners"
  type = list(object({
    name                     = string
    default_backend_set_name = string
    port                     = number
    protocol                 = string
    connection_configuration = object({
      idle_timeout_in_seconds = number
    })
    ssl_configuration = object({
      certificate_name        = string
      verify_peer_certificate = bool
      verify_depth            = number
    })
  }))
  default = []
}

variable "certificates" {
  description = "Certificados SSL para o Load Balancer"
  type = list(object({
    certificate_name   = string
    ca_certificate     = string
    private_key        = string
    public_certificate = string
  }))
  default = []
}

variable "path_route_sets" {
  description = "Conjuntos de rotas por path"
  type = list(object({
    name = string
    path_routes = list(object({
      backend_set_name = string
      path             = string
      match_type       = string
    }))
  }))
  default = []
}

variable "rule_sets" {
  description = "Conjuntos de regras para manipulação de requests/responses"
  type = list(object({
    name = string
    items = list(object({
      action = string
      conditions = list(object({
        attribute_name  = string
        attribute_value = string
        operator        = string
      }))
      redirect_uri = string
      header       = string
      value        = string
      prefix       = string
      suffix       = string
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
