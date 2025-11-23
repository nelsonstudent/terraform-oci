# Módulo IAM - OCI Terraform

Este módulo cria e gerencia recursos de Identity and Access Management (IAM) na Oracle Cloud Infrastructure (OCI), incluindo compartments, grupos, usuários, políticas e controles de acesso.

## Recursos Criados

- **Compartments** - Organização hierárquica de recursos
- **Groups** - Grupos de usuários para gerenciamento de permissões
- **Users** - Contas de usuários
- **User Group Memberships** - Associação de usuários a grupos
- **Policies** - Políticas de permissões IAM
- **Dynamic Groups** - Grupos baseados em regras para instâncias e serviços
- **API Keys** - Chaves de API para autenticação programática
- **Auth Tokens** - Tokens para OCIR e outros serviços
- **Customer Secret Keys** - Chaves para compatibilidade S3
- **Network Sources** - Restrições de acesso baseadas em IP
- **Tag Namespaces** - Organização de tags personalizadas

## Uso Básico

```hcl
module "iam" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id
  
  # Criar compartments
  compartments = [
    {
      name          = "development"
      description   = "Development environment"
      enable_delete = true
    },
    {
      name          = "production"
      description   = "Production environment"
      enable_delete = false
    }
  ]
  
  # Criar grupos
  groups = [
    {
      name        = "Developers"
      description = "Development team"
    },
    {
      name        = "Operators"
      description = "Operations team"
    }
  ]
  
  # Criar usuários
  users = [
    {
      name        = "john.wick"
      description = "Developer"
      email       = "john.wick@company.com"
      groups      = ["Developers"]
    }
  ]
  
  # Criar políticas
  policies = [
    {
      name           = "dev-policy"
      description    = "Policy for developers"
      compartment_id = null  # Usa parent_compartment_id
      statements = [
        "Allow group Developers to manage all-resources in compartment development",
        "Allow group Developers to read all-resources in compartment production"
      ]
    }
  ]
  
  tags = {
    ManagedBy = "Terraform"
    Team      = "Platform"
  }
}
```

## Variáveis

### Obrigatórias

| Nome | Descrição | Tipo |
|------|-----------|------|
| `tenancy_ocid` | OCID do tenancy | `string` |
| `parent_compartment_id` | OCID do compartment pai | `string` |

### Opcionais

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `compartments` | Lista de compartments | `list(object)` | `[]` |
| `groups` | Lista de grupos | `list(object)` | `[]` |
| `users` | Lista de usuários | `list(object)` | `[]` |
| `policies` | Lista de políticas | `list(object)` | `[]` |
| `dynamic_groups` | Lista de dynamic groups | `list(object)` | `[]` |
| `api_keys` | API keys para usuários | `list(object)` | `[]` |
| `auth_tokens` | Auth tokens para usuários | `list(object)` | `[]` |
| `customer_secret_keys` | Customer secret keys | `list(object)` | `[]` |
| `network_sources` | Network sources (IP whitelist) | `list(object)` | `[]` |
| `tag_namespaces` | Tag namespaces | `list(object)` | `[]` |
| `tags` | Tags freeform | `map(string)` | `{}` |
| `defined_tags` | Tags definidas | `map(string)` | `{}` |

### Estruturas de Objetos

#### Compartment
```hcl
{
  name          = string  # Nome do compartment
  description   = string  # Descrição
  enable_delete = bool    # Permitir deleção (false para produção)
}
```

#### Group
```hcl
{
  name        = string  # Nome do grupo
  description = string  # Descrição
}
```

#### User
```hcl
{
  name        = string         # Nome do usuário (username)
  description = string         # Descrição
  email       = string         # Email do usuário
  groups      = list(string)   # Lista de grupos que o usuário pertence
}
```

#### Policy
```hcl
{
  name           = string         # Nome da política
  description    = string         # Descrição
  compartment_id = string         # OCID do compartment (null = parent)
  statements     = list(string)   # Lista de statements da política
}
```

#### Dynamic Group
```hcl
{
  name          = string  # Nome do dynamic group
  description   = string  # Descrição
  matching_rule = string  # Regra de matching
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| `compartment_ids` | Map de nomes e IDs dos compartments |
| `group_ids` | Map de nomes e IDs dos grupos |
| `user_ids` | Map de nomes e IDs dos usuários |
| `policy_ids` | Map de nomes e IDs das políticas |
| `dynamic_group_ids` | Map de nomes e IDs dos dynamic groups |
| `auth_tokens` | Auth tokens criados (sensível) |
| `customer_secret_keys` | Customer secret keys (sensível) |
| `tag_namespace_ids` | Map de nomes e IDs dos tag namespaces |

## Exemplos de Uso

### Exemplo 1: Estrutura Organizacional Básica

```hcl
module "organization" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.tenancy_ocid  # Root compartment
  
  # Estrutura de compartments
  compartments = [
    {
      name          = "shared-services"
      description   = "Shared services (networking, monitoring)"
      enable_delete = false
    },
    {
      name          = "development"
      description   = "Development workloads"
      enable_delete = true
    },
    {
      name          = "staging"
      description   = "Staging environment"
      enable_delete = true
    },
    {
      name          = "production"
      description   = "Production workloads"
      enable_delete = false
    }
  ]
  
  # Grupos por função
  groups = [
    {
      name        = "NetworkAdmins"
      description = "Network administrators"
    },
    {
      name        = "Developers"
      description = "Application developers"
    },
    {
      name        = "DevOps"
      description = "DevOps engineers"
    },
    {
      name        = "ReadOnly"
      description = "Read-only access"
    }
  ]
  
  # Políticas
  policies = [
    {
      name           = "network-admin-policy"
      description    = "Full network management"
      compartment_id = null
      statements = [
        "Allow group NetworkAdmins to manage virtual-network-family in tenancy",
        "Allow group NetworkAdmins to manage load-balancers in tenancy"
      ]
    },
    {
      name           = "developer-policy"
      description    = "Developer access to dev environment"
      compartment_id = null
      statements = [
        "Allow group Developers to manage all-resources in compartment development",
        "Allow group Developers to read all-resources in compartment staging",
        "Allow group Developers to read metrics in compartment production"
      ]
    },
    {
      name           = "devops-policy"
      description    = "DevOps full access except IAM"
      compartment_id = null
      statements = [
        "Allow group DevOps to manage all-resources in compartment development",
        "Allow group DevOps to manage all-resources in compartment staging",
        "Allow group DevOps to manage instance-family in compartment production",
        "Allow group DevOps to manage cluster-family in compartment production"
      ]
    },
    {
      name           = "readonly-policy"
      description    = "Read-only access to all environments"
      compartment_id = null
      statements = [
        "Allow group ReadOnly to read all-resources in tenancy"
      ]
    }
  ]
  
  tags = {
    ManagedBy = "Terraform"
    Team      = "Platform"
  }
}
```

### Exemplo 2: Multi-tenant com Compartments por Cliente

```hcl
module "multi_tenant_iam" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.platform_compartment_id
  
  # Compartment por cliente
  compartments = [
    {
      name          = "client-acme"
      description   = "ACME Corporation resources"
      enable_delete = false
    },
    {
      name          = "client-globex"
      description   = "Globex Corporation resources"
      enable_delete = false
    },
    {
      name          = "client-initech"
      description   = "Initech resources"
      enable_delete = false
    }
  ]
  
  # Grupos por cliente
  groups = [
    {
      name        = "ACME-Admins"
      description = "ACME administrators"
    },
    {
      name        = "ACME-Users"
      description = "ACME users"
    },
    {
      name        = "Globex-Admins"
      description = "Globex administrators"
    },
    {
      name        = "Globex-Users"
      description = "Globex users"
    }
  ]
  
  # Políticas isoladas por cliente
  policies = [
    {
      name           = "acme-admin-policy"
      description    = "ACME admin access"
      compartment_id = null
      statements = [
        "Allow group ACME-Admins to manage all-resources in compartment client-acme"
      ]
    },
    {
      name           = "acme-user-policy"
      description    = "ACME user access"
      compartment_id = null
      statements = [
        "Allow group ACME-Users to read all-resources in compartment client-acme",
        "Allow group ACME-Users to manage instance-family in compartment client-acme"
      ]
    },
    {
      name           = "globex-admin-policy"
      description    = "Globex admin access"
      compartment_id = null
      statements = [
        "Allow group Globex-Admins to manage all-resources in compartment client-globex"
      ]
    }
  ]
  
  tags = {
    Platform  = "Multi-tenant"
    ManagedBy = "Terraform"
  }
}
```

### Exemplo 3: Dynamic Groups para Automação

```hcl
module "automation_iam" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id
  
  # Dynamic groups para instâncias e serviços
  dynamic_groups = [
    {
      name        = "oke-nodes"
      description = "All OKE worker nodes"
      matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}', instance.metadata.cluster = 'oke'}"
    },
    {
      name        = "compute-instances"
      description = "All compute instances"
      matching_rule = "ANY {instance.compartment.id = '${var.compartment_id}'}"
    },
    {
      name        = "functions"
      description = "All functions"
      matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_id}'}"
    }
  ]
  
  # Políticas para dynamic groups
  policies = [
    {
      name           = "oke-node-policy"
      description    = "Allow OKE nodes to pull images and access services"
      compartment_id = null
      statements = [
        "Allow dynamic-group oke-nodes to read repos in compartment id ${var.compartment_id}",
        "Allow dynamic-group oke-nodes to use keys in compartment id ${var.compartment_id}",
        "Allow dynamic-group oke-nodes to manage objects in compartment id ${var.compartment_id}"
      ]
    },
    {
      name           = "instance-policy"
      description    = "Allow instances to access Object Storage"
      compartment_id = null
      statements = [
        "Allow dynamic-group compute-instances to read buckets in compartment id ${var.compartment_id}",
        "Allow dynamic-group compute-instances to manage objects in compartment id ${var.compartment_id}"
      ]
    },
    {
      name           = "function-policy"
      description    = "Allow functions to access resources"
      compartment_id = null
      statements = [
        "Allow dynamic-group functions to use virtual-network-family in compartment id ${var.compartment_id}",
        "Allow dynamic-group functions to read secret-family in compartment id ${var.compartment_id}"
      ]
    }
  ]
  
  tags = {
    Purpose   = "Automation"
    ManagedBy = "Terraform"
  }
}
```

### Exemplo 4: Usuários com API Keys

```hcl
module "api_users" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id
  
  groups = [
    {
      name        = "APIUsers"
      description = "Users with API access"
    }
  ]
  
  users = [
    {
      name        = "ci-cd-user"
      description = "CI/CD automation user"
      email       = "cicd@company.com"
      groups      = ["APIUsers"]
    },
    {
      name        = "monitoring-user"
      description = "Monitoring system user"
      email       = "monitoring@company.com"
      groups      = ["APIUsers"]
    }
  ]
  
  # API Keys (você precisa gerar as chaves antes)
  api_keys = [
    {
      user_name  = "ci-cd-user"
      key_name   = "cicd-key-1"
      public_key = file("~/.oci/ci-cd-public-key.pem")
    }
  ]
  
  # Auth tokens para OCIR
  auth_tokens = [
    {
      user_name   = "ci-cd-user"
      description = "Token for OCIR access"
    }
  ]
  
  policies = [
    {
      name           = "api-user-policy"
      description    = "API user permissions"
      compartment_id = null
      statements = [
        "Allow group APIUsers to read all-resources in compartment id ${var.compartment_id}",
        "Allow group APIUsers to manage repos in compartment id ${var.compartment_id}",
        "Allow group APIUsers to manage cluster-family in compartment id ${var.compartment_id}"
      ]
    }
  ]
}
```

### Exemplo 5: Network Sources (IP Whitelisting)

```hcl
module "secure_iam" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id
  
  groups = [
    {
      name        = "RemoteAdmins"
      description = "Remote administrators"
    }
  ]
  
  # Restrição de IP
  network_sources = [
    {
      name        = "office-ips"
      description = "Office IP addresses"
      ip_ranges   = [
        "203.0.113.0/24",    # Office network
        "198.51.100.0/24"    # VPN network
      ]
      vcn_ids = null
    },
    {
      name        = "vpn-vcn"
      description = "Internal VPN VCN"
      ip_ranges   = []
      vcn_ids     = [var.vpn_vcn_id]
    }
  ]
  
  policies = [
    {
      name           = "remote-admin-policy"
      description    = "Remote admin access with IP restriction"
      compartment_id = null
      statements = [
        "Allow group RemoteAdmins to manage all-resources in tenancy where request.networkSource.name='office-ips'"
      ]
    }
  ]
}
```

### Exemplo 6: Tag Namespaces para Organização

```hcl
module "tagging_structure" {
  source = "../../modules/iam"
  
  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id
  
  tag_namespaces = [
    {
      name        = "CostTracking"
      description = "Tags for cost allocation"
      is_retired  = false
      tags = [
        {
          name        = "CostCenter"
          description = "Cost center identifier"
        },
        {
          name        = "Project"
          description = "Project name"
        },
        {
          name        = "Owner"
          description = "Resource owner"
        }
      ]
    },
    {
      name        = "Compliance"
      description = "Compliance and security tags"
      is_retired  = false
      tags = [
        {
          name        = "DataClassification"
          description = "Data classification level"
        },
        {
          name        = "ComplianceFramework"
          description = "Applicable compliance framework"
        }
      ]
    }
  ]
  
  tags = {
    Purpose   = "Governance"
    ManagedBy = "Terraform"
  }
}
```

## Políticas IAM

### Formato de Policy Statements

```
Allow <subject> to <verb> <resource-type> in <location> where <conditions>
```

### Subjects
- `group <group-name>` - Grupo de usuários
- `dynamic-group <dg-name>` - Dynamic group
- `any-user` - Qualquer usuário autenticado
- `service <service-name>` - Serviço OCI

### Verbs (Níveis de Acesso)
- `inspect` - Listar recursos (read-only mínimo)
- `read` - Ler detalhes dos recursos
- `use` - Usar recursos existentes
- `manage` - Controle total (create, update, delete)

### Resource Types Comuns
- `all-resources` - Todos os recursos
- `instance-family` - Compute instances
- `virtual-network-family` - VCN, subnets, etc
- `cluster-family` - OKE clusters
- `database-family` - Databases
- `repos` - Container registry
- `buckets` - Object Storage

### Exemplos de Statements

```hcl
# Acesso total a um compartment
"Allow group Admins to manage all-resources in compartment Development"

# Acesso read-only
"Allow group Auditors to read all-resources in tenancy"

# Acesso específico a compute
"Allow group Developers to manage instance-family in compartment Development"

# Acesso com condição
"Allow group RemoteUsers to manage all-resources in compartment Production where request.networkSource.name='office-ips'"

# Dynamic group
"Allow dynamic-group oke-nodes to read repos in compartment Production"

# Service access
"Allow service FaaS to use virtual-network-family in compartment Development"
```

## Melhores Práticas

### Organização de Compartments

```
Root (Tenancy)
├── shared-services/
│   ├── networking
│   ├── monitoring
│   └── security
├── development/
│   ├── app-1
│   └── app-2
├── staging/
│   ├── app-1
│   └── app-2
└── production/
    ├── app-1
    └── app-2
```

### Estratégia de Grupos

1. **Grupos por Função**
   - Developers
   - Operators
   - DBAs
   - NetworkAdmins

2. **Grupos por Ambiente**
   - Dev-Users
   - Prod-ReadOnly
   - Staging-Admins

3. **Grupos por Aplicação**
   - App1-Admins
   - App2-Users

### Princípios de Segurança

✅ **Least Privilege** - Dê apenas as permissões necessárias  
✅ **Separation of Duties** - Separe responsabilidades  
✅ **Defense in Depth** - Múltiplas camadas de segurança  
✅ **Regular Audits** - Revise permissões regularmente  
✅ **Use Dynamic Groups** - Para automação e serviços  

## Matching Rules para Dynamic Groups

### Por Compartment
```hcl
"instance.compartment.id = 'ocid1.compartment.oc1..aaaa'"
```

### Por Tag
```hcl
"tag.Environment.value = 'production'"
```

### Por Tipo de Recurso
```hcl
"resource.type = 'fnfunc'"  # Functions
"resource.type = 'cluster'"  # OKE clusters
```

### Múltiplas Condições (ALL)
```hcl
"ALL {instance.compartment.id = 'ocid...', tag.Environment.value = 'prod'}"
```

### Múltiplas Condições (ANY)
```hcl
"ANY {instance.compartment.id = 'ocid1...', instance.compartment.id = 'ocid2...'}"
```

## Auditoria e Compliance

### Listar Usuários e Grupos

```bash
# Via OCI CLI
oci iam user list --compartment-id <tenancy-ocid>
oci iam group list --compartment-id <tenancy-ocid>

# Via Terraform
terraform state show 'module.iam.oci_identity_user.this["john.doe"]'
```

### Exportar Políticas

```bash
# Listar todas as políticas
oci iam policy list --compartment-id <compartment-ocid> --all

# Ver detalhes de uma política
oci iam policy get --policy-id <policy-ocid>
```

### Auditoria de Acesso

```hcl
# Habilitar audit logs
resource "oci_logging_log" "audit_log" {
  display_name = "AuditLog"
  log_group_id = var.log_group_id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "all"
      resource    = var.compartment_id
      service     = "iam"
      source_type = "OCISERVICE"
    }
  }
}
```

## Troubleshooting

### Erro: "NotAuthorizedOrNotFound"

**Causa**: Usuário não tem permissão ou recurso não existe  
**Solução**: Verifique políticas IAM e compartments

```bash
# Ver políticas do grupo
oci iam policy list --compartment-id <tenancy-ocid>
```

### Erro: "CompartmentAlreadyExists"

**Causa**: Compartment com mesmo nome já existe  
**Solução**: Use nome único ou importe recurso existente

```bash
terraform import 'module.iam.oci_identity_compartment.this["dev"]' <compartment-ocid>
```

### Dynamic Group não funciona

**Causa**: Matching rule incorreta  
**Solução**: Teste a regra

```bash
# Verificar se instância está no dynamic group
oci compute instance list --compartment-id <id>
```

### Usuário não consegue fazer login

**Causa**: Usuário pode não estar no grupo correto  
**Solução**: Verifique memberships

```bash
oci iam user-group-membership list --user-id <user-ocid>
```

## Recursos Adicionais

- [OCI IAM Documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/home.htm)
- [Policy Reference](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm)
- [IAM Best Practices](https://docs.oracle.com/en-us/iaas/Content/Security/Reference/iam_security.htm)
