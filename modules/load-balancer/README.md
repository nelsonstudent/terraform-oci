# Módulo Load Balancer - OCI Terraform

Este módulo cria e configura Load Balancers na Oracle Cloud Infrastructure (OCI), incluindo backend sets, listeners, certificados SSL, health checks e regras de roteamento.

## Recursos Criados

- **Load Balancer** - LB público ou privado com shape flexível
- **Backend Sets** - Grupos de servidores backend com health checks
- **Backends** - Servidores individuais nos backend sets
- **Listeners** - Pontos de entrada para tráfego (HTTP/HTTPS/TCP)
- **Certificates** - Certificados SSL/TLS
- **Path Route Sets** - Roteamento baseado em URL path
- **Rule Sets** - Regras para manipulação de headers e redirects

## Uso Básico

```hcl
module "load_balancer" {
  source = "../../modules/load-balancer"
  
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaxxxxxx"
  lb_name        = "web-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = 10
  lb_max_bandwidth_mbps = 100
  
  subnet_ids = ["ocid1.subnet.oc1..aaaaaaaaxxxxxx"]
  is_private = false
  
  backend_sets = [
    {
      name   = "web-backend"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 80
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.1.10"
          port       = 80
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "http"
      default_backend_set_name = "web-backend"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = null
      ssl_configuration        = null
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

## Variáveis Principais

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|-------------|
| `compartment_id` | ID do compartment | `string` | - | Sim |
| `lb_name` | Nome do Load Balancer | `string` | - | Sim |
| `lb_shape` | Shape do LB | `string` | `"flexible"` | Não |
| `subnet_ids` | IDs das subnets | `list(string)` | - | Sim |
| `is_private` | Se o LB é privado | `bool` | `false` | Não |

### Variáveis de Shape

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `lb_min_bandwidth_mbps` | Bandwidth mínima (Mbps) | `number` | `10` |
| `lb_max_bandwidth_mbps` | Bandwidth máxima (Mbps) | `number` | `100` |

### Backend Sets

```hcl
backend_sets = [
  {
    name   = string              # Nome do backend set
    policy = string              # ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH
    
    health_checker = {
      protocol            = string  # HTTP, HTTPS, TCP
      port                = number
      url_path            = string  # Para HTTP/HTTPS
      return_code         = number  # Código HTTP esperado
      interval_ms         = number  # Intervalo entre checks
      timeout_in_millis   = number
      retries             = number
      response_body_regex = string  # Regex opcional
    }
    
    # Opcional: Persistência de sessão
    session_persistence_cookie_name      = string
    session_persistence_disable_fallback = bool
    
    # Opcional: SSL backend
    ssl_configuration = {
      certificate_name        = string
      verify_depth            = number
      verify_peer_certificate = bool
    }
    
    backends = [
      {
        ip_address = string  # IP do servidor backend
        port       = number  # Porta do serviço
        backup     = bool    # Servidor de backup
        drain      = bool    # Modo drain (não aceita novas conexões)
        offline    = bool    # Temporariamente offline
        weight     = number  # Peso para balanceamento (1-100)
      }
    ]
  }
]
```

### Listeners

```hcl
listeners = [
  {
    name                     = string  # Nome do listener
    default_backend_set_name = string  # Backend set padrão
    port                     = number  # Porta de escuta
    protocol                 = string  # HTTP, HTTPS, TCP
    
    # Opcional: Configuração de conexão
    connection_configuration = {
      idle_timeout_in_seconds = number  # Timeout de conexão idle
    }
    
    # Opcional: SSL/TLS
    ssl_configuration = {
      certificate_name        = string
      verify_peer_certificate = bool
      verify_depth            = number
    }
  }
]
```

### Certificates

```hcl
certificates = [
  {
    certificate_name   = string  # Nome único
    ca_certificate     = string  # Certificado CA (PEM)
    private_key        = string  # Chave privada (PEM)
    public_certificate = string  # Certificado público (PEM)
  }
]
```

## Outputs

| Nome | Descrição |
|------|-----------|
| `load_balancer_id` | ID do Load Balancer |
| `load_balancer_ip_addresses` | Endereços IP do Load Balancer |
| `backend_set_names` | Nomes dos backend sets |
| `listener_names` | Nomes dos listeners |
| `certificate_names` | Nomes dos certificados |

## Exemplos de Uso

### Exemplo 1: Load Balancer HTTP Simples

```hcl
module "web_lb" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "web-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = 10
  lb_max_bandwidth_mbps = 100
  
  subnet_ids = module.network.public_subnet_ids
  
  backend_sets = [
    {
      name   = "web-servers"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 80
        url_path            = "/"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.1.10"
          port       = 80
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        },
        {
          ip_address = "10.0.1.11"
          port       = 80
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "http"
      default_backend_set_name = "web-servers"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 300
      }
      ssl_configuration = null
    }
  ]
}
```

### Exemplo 2: HTTPS com SSL Certificate

```hcl
module "secure_lb" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "secure-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = 10
  lb_max_bandwidth_mbps = 400
  
  subnet_ids = module.network.public_subnet_ids
  
  # Certificados SSL
  certificates = [
    {
      certificate_name = "main-cert"
      ca_certificate = file("${path.module}/certs/ca.pem")
      private_key = file("${path.module}/certs/private.key")
      public_certificate = file("${path.module}/certs/public.crt")
    }
  ]
  
  backend_sets = [
    {
      name   = "secure-backend"
      policy = "LEAST_CONNECTIONS"
      health_checker = {
        protocol            = "HTTPS"
        port                = 443
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 30000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ".*healthy.*"
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.1.20"
          port       = 443
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "https"
      default_backend_set_name = "secure-backend"
      port                     = 443
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 300
      }
      ssl_configuration = {
        certificate_name        = "main-cert"
        verify_peer_certificate = false
        verify_depth            = 5
      }
    }
  ]
}
```

### Exemplo 3: Múltiplos Backend Sets com Persistência de Sessão

```hcl
module "app_lb" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "app-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = 100
  lb_max_bandwidth_mbps = 400
  
  subnet_ids = module.network.public_subnet_ids
  
  backend_sets = [
    {
      name   = "app-backend"
      policy = "IP_HASH"  # Consistência baseada em IP
      health_checker = {
        protocol            = "HTTP"
        port                = 8080
        url_path            = "/actuator/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      # Persistência de sessão via cookie
      session_persistence_cookie_name      = "APP_SESSION"
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.10.10"
          port       = 8080
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        },
        {
          ip_address = "10.0.10.11"
          port       = 8080
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        },
        {
          ip_address = "10.0.10.12"
          port       = 8080
          backup     = true  # Servidor de backup
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    },
    {
      name   = "api-backend"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 3000
        url_path            = "/api/health"
        return_code         = 200
        interval_ms         = 15000
        timeout_in_millis   = 5000
        retries             = 2
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.10.20"
          port       = 3000
          backup     = false
          drain      = false
          offline    = false
          weight     = 2  # Peso maior
        },
        {
          ip_address = "10.0.10.21"
          port       = 3000
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "app-listener"
      default_backend_set_name = "app-backend"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 600
      }
      ssl_configuration = null
    },
    {
      name                     = "api-listener"
      default_backend_set_name = "api-backend"
      port                     = 8080
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 300
      }
      ssl_configuration = null
    }
  ]
}
```

### Exemplo 4: Path-Based Routing

```hcl
module "microservices_lb" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "microservices-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = 10
  lb_max_bandwidth_mbps = 400
  
  subnet_ids = module.network.public_subnet_ids
  
  backend_sets = [
    {
      name   = "service-a"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 8080
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.10.10"
          port       = 8080
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    },
    {
      name   = "service-b"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 8081
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        {
          ip_address = "10.0.10.20"
          port       = 8081
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "main"
      default_backend_set_name = "service-a"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = null
      ssl_configuration        = null
    }
  ]
  
  # Roteamento por path
  path_route_sets = [
    {
      name = "api-routes"
      path_routes = [
        {
          backend_set_name = "service-a"
          path             = "/api/service-a"
          match_type       = "PREFIX_MATCH"
        },
        {
          backend_set_name = "service-b"
          path             = "/api/service-b"
          match_type       = "PREFIX_MATCH"
        }
      ]
    }
  ]
}
```

## Load Balancer Shapes

### Flexible Shape (Recomendado)
```hcl
lb_shape              = "flexible"
lb_min_bandwidth_mbps = 10    # Mínimo: 10 Mbps
lb_max_bandwidth_mbps = 8000  # Máximo: 8000 Mbps
```

### Fixed Shapes
- **100Mbps** - 100 Mbps fixo
- **400Mbps** - 400 Mbps fixo
- **8000Mbps** - 8 Gbps fixo

## Load Balancing Policies

| Policy | Descrição | Uso Recomendado |
|--------|-----------|-----------------|
| **ROUND_ROBIN** | Distribui requisições sequencialmente | Tráfego geral, stateless |
| **LEAST_CONNECTIONS** | Envia para servidor com menos conexões | Conexões de longa duração |
| **IP_HASH** | Baseado no IP do cliente | Aplicações stateful |

## Health Checks

### Configuração Recomendada

```hcl
health_checker = {
  protocol            = "HTTP"
  port                = 80
  url_path            = "/health"      # Endpoint dedicado
  return_code         = 200
  interval_ms         = 10000          # 10 segundos
  timeout_in_millis   = 3000           # 3 segundos
  retries             = 3              # 3 falhas = unhealthy
  response_body_regex = ".*OK.*"       # Opcional
}
```

### Protocols Suportados
- **HTTP/HTTPS** - Verifica endpoint HTTP
- **TCP** - Verifica conectividade TCP

## Session Persistence

### Cookie-Based Persistence

```hcl
session_persistence_cookie_name      = "LB_SESSION"
session_persistence_disable_fallback = false
```

O Load Balancer insere um cookie para manter o cliente no mesmo backend.

## SSL/TLS Configuration

### Frontend SSL (Listener)

```hcl
ssl_configuration = {
  certificate_name        = "my-cert"
  verify_peer_certificate = false  # Cliente não precisa certificado
  verify_depth            = 5
}
```

### Backend SSL (Backend Set)

```hcl
ssl_configuration = {
  certificate_name        = "backend-cert"
  verify_depth            = 5
  verify_peer_certificate = true  # Verifica certificado do backend
}
```

## Load Balancer Privado vs Público

### Público (Padrão)
```hcl
is_private = false
subnet_ids = [public_subnet_id]  # Subnet pública
```
- Recebe tráfego da internet
- Possui IP público

### Privado
```hcl
is_private = true
subnet_ids = [private_subnet_id]  # Subnet privada
```
- Apenas tráfego interno
- Sem IP público

## Backend Management

### Adicionar Backend em Modo Drain

```hcl
backends = [
  {
    ip_address = "10.0.1.10"
    port       = 80
    drain      = true  # Não aceita novas conexões
    offline    = false
    backup     = false
    weight     = 1
  }
]
```

### Servidor de Backup

```hcl
backends = [
  {
    ip_address = "10.0.1.20"
    port       = 80
    backup     = true  # Só usado se outros falharem
    drain      = false
    offline    = false
    weight     = 1
  }
]
```

## Integração com Compute Module

```hcl
module "web_servers" {
  source = "../../modules/compute"
  # ... configurações ...
}

module "load_balancer" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "web-lb"
  lb_shape       = "flexible"
  
  subnet_ids = module.network.public_subnet_ids
  
  backend_sets = [
    {
      name   = "web-backend"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 80
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      # Usar IPs das instâncias criadas
      backends = [
        for ip in module.web_servers.instance_private_ips : {
          ip_address = ip
          port       = 80
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "http"
      default_backend_set_name = "web-backend"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = null
      ssl_configuration        = null
    }
  ]
  
  depends_on = [module.web_servers]
}
```

## Troubleshooting

### Backends aparecem como Unhealthy

1. **Verifique o Health Check**:
   ```bash
   curl -I http://<backend_ip>:<port>/health
   ```

2. **Security Lists/NSGs**: Certifique-se que o LB pode acessar os backends
3. **Return Code**: Verifique se o endpoint retorna o código esperado
4. **Timeout**: Aumente `timeout_in_millis` se backends são lentos

### Load Balancer não distribui tráfego

- Verifique se há backends healthy
- Confirme que o listener está na porta correta
- Para IP_HASH policy, mesmo cliente vai sempre para mesmo backend

### SSL Errors

- Verifique formato dos certificados (PEM)
- Confirme que certificado, chave privada e CA estão corretos
- Teste certificado: `openssl x509 -in cert.pem -text -noout`

### Performance Issues

- Aumente `lb_max_bandwidth_mbps` se necessário
- Considere usar policy LEAST_CONNECTIONS para melhor distribuição
- Adicione mais backends ao backend set

## Monitoramento

O Load Balancer automaticamente envia métricas para OCI Monitoring:

- **Requests per second**
- **Active connections**
- **Backend health status**
- **Response time**
- **Throughput**

Acesse via OCI Console > Monitoring > Metrics Explorer

## Requisitos

- Terraform >= 1.0
- Provider OCI >= 5.0
- Permissões necessárias no compartment
- Pelo menos uma subnet configurada
