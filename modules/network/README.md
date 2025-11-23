# Módulo Network - OCI Terraform

Este módulo cria uma infraestrutura de rede completa na Oracle Cloud Infrastructure (OCI), incluindo VCN, subnets públicas e privadas, gateways e configurações de segurança.

## Recursos Criados

- **VCN (Virtual Cloud Network)** - Rede virtual principal
- **Internet Gateway** - Conectividade para internet em subnets públicas
- **NAT Gateway** - Acesso à internet para subnets privadas
- **Service Gateway** - Acesso aos serviços Oracle sem usar internet pública
- **Route Tables** - Tabelas de roteamento para subnets públicas e privadas
- **Security Lists** - Regras de firewall para subnets públicas e privadas
- **Subnets Públicas** - Subnets com acesso direto à internet
- **Subnets Privadas** - Subnets isoladas com acesso via NAT Gateway

## Uso Básico

```hcl
module "network" {
  source = "../../modules/network"
  
  compartment_id  = "ocid1.compartment.oc1..aaaaaaaaxxxxxx"
  vcn_name        = "minha-vcn"
  vcn_cidr_blocks = ["10.0.0.0/16"]
  vcn_dns_label   = "minhavcn"
  
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
  
  public_subnets = [
    {
      name      = "public-subnet-1"
      cidr      = "10.0.1.0/24"
      dns_label = "public1"
    }
  ]
  
  private_subnets = [
    {
      name      = "private-subnet-1"
      cidr      = "10.0.10.0/24"
      dns_label = "private1"
    }
  ]
  
  allow_public_ssh   = false
  allow_public_http  = true
  allow_public_https = true
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Variáveis

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|-------------|
| `compartment_id` | ID do compartment onde os recursos serão criados | `string` | - | Sim |
| `vcn_name` | Nome da VCN | `string` | - | Sim |
| `vcn_cidr_blocks` | Lista de blocos CIDR para a VCN | `list(string)` | `["10.0.0.0/16"]` | Não |
| `vcn_dns_label` | DNS label para a VCN | `string` | `"vcn"` | Não |
| `create_internet_gateway` | Criar Internet Gateway | `bool` | `true` | Não |
| `create_nat_gateway` | Criar NAT Gateway | `bool` | `true` | Não |
| `create_service_gateway` | Criar Service Gateway | `bool` | `true` | Não |
| `public_subnets` | Lista de subnets públicas | `list(object)` | `[]` | Não |
| `private_subnets` | Lista de subnets privadas | `list(object)` | `[]` | Não |
| `allow_public_ssh` | Permitir SSH (porta 22) nas subnets públicas | `bool` | `false` | Não |
| `allow_public_http` | Permitir HTTP (porta 80) nas subnets públicas | `bool` | `true` | Não |
| `allow_public_https` | Permitir HTTPS (porta 443) nas subnets públicas | `bool` | `true` | Não |
| `tags` | Tags freeform para aplicar aos recursos | `map(string)` | `{}` | Não |
| `defined_tags` | Tags definidas para aplicar aos recursos | `map(string)` | `{}` | Não |

### Estrutura de Subnets

```hcl
{
  name      = string  # Nome da subnet
  cidr      = string  # Bloco CIDR (ex: "10.0.1.0/24")
  dns_label = string  # Label DNS (ex: "public1")
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| `vcn_id` | ID da VCN criada |
| `vcn_cidr_blocks` | Blocos CIDR da VCN |
| `internet_gateway_id` | ID do Internet Gateway |
| `nat_gateway_id` | ID do NAT Gateway |
| `service_gateway_id` | ID do Service Gateway |
| `public_subnet_ids` | IDs das subnets públicas |
| `private_subnet_ids` | IDs das subnets privadas |
| `public_route_table_id` | ID da route table pública |
| `private_route_table_id` | ID da route table privada |
| `public_security_list_id` | ID da security list pública |
| `private_security_list_id` | ID da security list privada |

## Exemplos de Uso

### Exemplo 1: VCN com múltiplas subnets

```hcl
module "network" {
  source = "../../modules/network"
  
  compartment_id  = var.compartment_id
  vcn_name        = "production-vcn"
  vcn_cidr_blocks = ["10.0.0.0/16"]
  
  public_subnets = [
    {
      name      = "public-subnet-ad1"
      cidr      = "10.0.1.0/24"
      dns_label = "publicsub1"
    },
    {
      name      = "public-subnet-ad2"
      cidr      = "10.0.2.0/24"
      dns_label = "publicsub2"
    }
  ]
  
  private_subnets = [
    {
      name      = "private-app-ad1"
      cidr      = "10.0.10.0/24"
      dns_label = "privateapp1"
    },
    {
      name      = "private-db-ad1"
      cidr      = "10.0.20.0/24"
      dns_label = "privatedb1"
    }
  ]
}
```

### Exemplo 2: VCN privada (sem Internet Gateway)

```hcl
module "network" {
  source = "../../modules/network"
  
  compartment_id  = var.compartment_id
  vcn_name        = "private-vcn"
  vcn_cidr_blocks = ["172.16.0.0/16"]
  
  create_internet_gateway = false
  create_nat_gateway      = true
  create_service_gateway  = true
  
  private_subnets = [
    {
      name      = "app-subnet"
      cidr      = "172.16.10.0/24"
      dns_label = "appsub"
    }
  ]
}
```

## Considerações de Segurança

### Security Lists Padrão

**Subnet Pública:**
- Egress: Permite todo tráfego de saída
- Ingress: Controlado pelas variáveis `allow_public_*`
  - SSH (22): Opcional via `allow_public_ssh`
  - HTTP (80): Opcional via `allow_public_http`
  - HTTPS (443): Opcional via `allow_public_https`

**Subnet Privada:**
- Egress: Permite todo tráfego de saída
- Ingress: Permite todo tráfego vindo do CIDR da VCN

### Recomendações

1. **Produção**: Sempre use `allow_public_ssh = false` e acesse via Bastion Host
2. **Network Security Groups**: Para controle mais granular, use NSGs em vez de Security Lists
3. **Múltiplas Subnets**: Separe diferentes tiers (web, app, db) em subnets distintas
4. **Service Gateway**: Sempre habilite para acesso otimizado aos serviços Oracle

## Arquitetura Típica

```
┌────────────────────────────────────────────────────────────┐
│                        VCN (10.0.0.0/16)                   │
│                                                            │
│  ┌─────────────────────┐         ┌─────────────────────┐   │
│  │  Internet Gateway   │         │   Service Gateway   │   │
│  └──────────┬──────────┘         └──────────┬──────────┘   │
│             │                                │             │
│  ┌──────────▼──────────┐         ┌──────────▼──────────┐   │
│  │  Public Subnet      │         │  NAT Gateway        │   │
│  │  10.0.1.0/24        │         └──────────┬──────────┘   │
│  │                     │                    │              │
│  │  - Load Balancers   │         ┌──────────▼──────────┐   │
│  │  - Bastion Hosts    │         │  Private Subnet     │   │
│  └─────────────────────┘         │  10.0.10.0/24       │   │
│                                  │                     │   │
│                                  │  - App Servers      │   │
│                                  │  - Databases        │   │
│                                  └─────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Erro: "Service not available"
- Verifique se o Service Gateway está habilitado
- Confirme a região suporta Service Gateway

### Subnets não conseguem acessar internet
- **Pública**: Verifique se Internet Gateway está criado e associado à route table
- **Privada**: Verifique se NAT Gateway está criado e associado à route table

### Conflito de CIDR
- Certifique-se que os CIDRs das subnets não se sobrepõem
- Verifique se o CIDR da VCN comporta todas as subnets

## Requisitos

- Terraform >= 1.0
- Provider OCI >= 5.0
- Permissões necessárias no compartment para criar recursos de rede
