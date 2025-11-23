# Módulo para criar Load Balancer (Network e Application)

# Load Balancer
resource "oci_load_balancer_load_balancer" "this" {
  compartment_id = var.compartment_id
  display_name   = var.lb_name
  shape          = var.lb_shape
  subnet_ids     = var.subnet_ids
  
  dynamic "shape_details" {
    for_each = var.lb_shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.lb_min_bandwidth_mbps
      maximum_bandwidth_in_mbps = var.lb_max_bandwidth_mbps
    }
  }
  
  is_private                = var.is_private
  network_security_group_ids = var.nsg_ids
  
  dynamic "reserved_ips" {
    for_each = var.reserved_ip_id != null ? [1] : []
    content {
      id = var.reserved_ip_id
    }
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Backend Set
resource "oci_load_balancer_backend_set" "this" {
  for_each         = { for bs in var.backend_sets : bs.name => bs }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = each.value.name
  policy           = each.value.policy
  
  health_checker {
    protocol            = each.value.health_checker.protocol
    port                = each.value.health_checker.port
    url_path            = each.value.health_checker.url_path
    return_code         = each.value.health_checker.return_code
    interval_ms         = each.value.health_checker.interval_ms
    timeout_in_millis   = each.value.health_checker.timeout_in_millis
    retries             = each.value.health_checker.retries
    response_body_regex = each.value.health_checker.response_body_regex
  }
  
  dynamic "session_persistence_configuration" {
    for_each = each.value.session_persistence_cookie_name != null ? [1] : []
    content {
      cookie_name      = each.value.session_persistence_cookie_name
      disable_fallback = each.value.session_persistence_disable_fallback
    }
  }
  
  dynamic "ssl_configuration" {
    for_each = each.value.ssl_configuration != null ? [1] : []
    content {
      certificate_name        = each.value.ssl_configuration.certificate_name
      verify_depth            = each.value.ssl_configuration.verify_depth
      verify_peer_certificate = each.value.ssl_configuration.verify_peer_certificate
    }
  }
}

# Backends
resource "oci_load_balancer_backend" "this" {
  for_each = {
    for backend in flatten([
      for bs in var.backend_sets : [
        for b in bs.backends : {
          backend_set_name = bs.name
          ip_address       = b.ip_address
          port             = b.port
          backup           = b.backup
          drain            = b.drain
          offline          = b.offline
          weight           = b.weight
          key              = "${bs.name}-${b.ip_address}-${b.port}"
        }
      ]
    ]) : backend.key => backend
  }
  
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = each.value.backend_set_name
  ip_address       = each.value.ip_address
  port             = each.value.port
  backup           = each.value.backup
  drain            = each.value.drain
  offline          = each.value.offline
  weight           = each.value.weight
  
  depends_on = [oci_load_balancer_backend_set.this]
}

# Listeners
resource "oci_load_balancer_listener" "this" {
  for_each                   = { for listener in var.listeners : listener.name => listener }
  load_balancer_id           = oci_load_balancer_load_balancer.this.id
  name                       = each.value.name
  default_backend_set_name   = each.value.default_backend_set_name
  port                       = each.value.port
  protocol                   = each.value.protocol
  
  dynamic "connection_configuration" {
    for_each = each.value.connection_configuration != null ? [1] : []
    content {
      idle_timeout_in_seconds = each.value.connection_configuration.idle_timeout_in_seconds
    }
  }
  
  dynamic "ssl_configuration" {
    for_each = each.value.ssl_configuration != null ? [1] : []
    content {
      certificate_name        = each.value.ssl_configuration.certificate_name
      verify_peer_certificate = each.value.ssl_configuration.verify_peer_certificate
      verify_depth            = each.value.ssl_configuration.verify_depth
    }
  }
  
  depends_on = [oci_load_balancer_backend_set.this]
}

# Certificates
resource "oci_load_balancer_certificate" "this" {
  for_each         = { for cert in var.certificates : cert.certificate_name => cert }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  certificate_name = each.value.certificate_name
  
  ca_certificate     = each.value.ca_certificate
  private_key        = each.value.private_key
  public_certificate = each.value.public_certificate
  
  lifecycle {
    create_before_destroy = true
  }
}

# Path Route Sets
resource "oci_load_balancer_path_route_set" "this" {
  for_each         = { for prs in var.path_route_sets : prs.name => prs }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = each.value.name
  
  dynamic "path_routes" {
    for_each = each.value.path_routes
    content {
      backend_set_name = path_routes.value.backend_set_name
      path             = path_routes.value.path
      path_match_type {
        match_type = path_routes.value.match_type
      }
    }
  }
  
  depends_on = [oci_load_balancer_backend_set.this]
}

# Rule Sets
resource "oci_load_balancer_rule_set" "this" {
  for_each         = { for rs in var.rule_sets : rs.name => rs }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = each.value.name
  
  dynamic "items" {
    for_each = each.value.items
    content {
      action = items.value.action
      
      # Headers
      dynamic "conditions" {
        for_each = items.value.conditions != null ? items.value.conditions : []
        content {
          attribute_name  = conditions.value.attribute_name
          attribute_value = conditions.value.attribute_value
          operator        = conditions.value.operator
        }
      }

      # Se a ação for de redirecionamento, use o sub-bloco `redirect_uri`
      dynamic "redirect_uri" {
        for_each = items.value.action == "REDIRECT" ? [1] : []
        content {
          protocol                    = lookup(items.value, "protocol", null)
          port                        = lookup(items.value, "port", null)
          host                        = lookup(items.value, "host", null)
          path                        = lookup(items.value, "path", null)
          query                       = lookup(items.value, "query", null)
        }
      }
      
      # Se a ação for de manipulação de cabeçalho, use o sub-bloco `header_actions`
      dynamic "header_actions" {
        for_each = items.value.action == "ADD_HTTP_REQUEST_HEADER" || items.value.action == "REMOVE_HTTP_REQUEST_HEADER" || items.value.action == "SET_HTTP_REQUEST_HEADER" ? [1] : []
        content {
          option              = lookup(items.value, "option", null)
          header              = lookup(items.value, "header", null)
          value               = lookup(items.value, "value", null)
          http_response_code          = lookup(items.value, "http_response_code", null)
        }
      }
    }
  }
}
