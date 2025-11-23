# Terraform OCI Modules

[![Terraform](https://img.shields.io/badge/Terraform-≥1.0-623CE4?style=flat&logo=terraform)](https://www.terraform.io/)
[![OCI Provider](https://img.shields.io/badge/OCI_Provider-≥5.0-F80000?style=flat&logo=oracle)](https://registry.terraform.io/providers/oracle/oci)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Coleção completa e profissional de módulos Terraform para Oracle Cloud Infrastructure (OCI), projetada para acelerar o provisionamento de infraestrutura para múltiplos clientes com qualidade enterprise.

## Índice

- [Visão Geral](#-visão-geral)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Módulos Disponíveis](#-módulos-disponíveis)
- [Início Rápido](#-início-rápido)
- [Como Adicionar Novo Cliente](#-como-adicionar-novo-cliente)
- [Exemplos de Uso](#-exemplos-de-uso)
- [Arquiteturas de Referência](#-arquiteturas-de-referência)
- [Segurança](#-segurança)
- [Melhores Práticas](#-melhores-práticas)
- [CI/CD](#-cicd)
- [Troubleshooting](#-troubleshooting)
- [Contribuindo](#-contribuindo)

## Visão Geral

Este projeto fornece módulos Terraform battle-tested e production-ready para OCI, permitindo:

✅ **Reutilização** - Módulos prontos para usar em múltiplos clientes  
✅ **Consistência** - Padrões e melhores práticas incorporados  
✅ **Velocidade** - Provisione infraestrutura completa em minutos  
✅ **Segurança** - Security by default em todos os módulos  
✅ **Documentação** - Cada módulo possui README completo com exemplos  
✅ **Manutenibilidade** - Código limpo, organizado e versionado  
✅ **Multi-Cliente** - Estrutura preparada para gerenciar múltiplos clientes

### Benefícios

- **Para DevOps/SRE**: Reduza tempo de provisionamento de dias para horas
- **Para Empresas**: Padronize infraestrutura entre projetos e clientes
- **Para Desenvolvedores**: Foque na aplicação, não na infraestrutura
- **Para Gestores**: Controle de custos e compliance facilitados

## Estrutura do Projeto

```
terraform-oci-modules/
├── modules/                           # Módulos reutilizáveis
│   ├── compartment/                  # Compartments OCI
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/                      # Instâncias e volumes
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── container-registry/           # OCIR
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── database/                     # Bancos de dados gerenciados
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── iam/                          # Identity & Access Management
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── kubernetes/                   # OKE
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── load-balancer/               # Load Balancers
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── network/                      # VCN e conectividade
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── storage/                      # Storage services
│   │   ├── block-storage/            # Block Volumes
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── README.md
│   │   └── file-storage/             # File Storage (NFS)
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── README.md
│   │       ├── file-system/          
│   │       ├── mount-target/
│   │       ├── export-set/
│   │       └── export/
│   └── waf/                          # Web Application Firewall
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── environments/                     # Configurações por cliente
│   ├── client-example/              # Exemplo básico (Web + DB)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── full-stack-example/          # Exemplo completo (All modules)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── README.md
│   └── README.md
├── .gitignore                        # Arquivos ignorados
└── README.md                         # Este arquivo
```

## Módulos Disponíveis

| Módulo | Descrição | Recursos | Documentação |
|--------|-----------|----------|--------------|
| **[Compartment](modules/compartment/)** | Compartments OCI | Compartments hierárquicos para organização | [📖 README](modules/compartment/README.md) |
| **[Compute](modules/compute/)** | VMs e Bare Metal | Instâncias, Boot/Block Volumes, Cloud-init, NSG | [📖 README](modules/compute/README.md) |
| **[Container Registry](modules/container-registry/)** | OCIR | Repositórios privados/públicos, Image signatures | [📖 README](modules/container-registry/README.md) |
| **[Database](modules/database/)** | Bancos de Dados Gerenciados | Autonomous DB, MySQL, PostgreSQL, Backups, HA | [📖 README](modules/database/README.md) |
| **[IAM](modules/iam/)** | Identity & Access Management | Grupos, Usuários, Políticas, Dynamic Groups, Tags | [📖 README](modules/iam/README.md) |
| **[Kubernetes](modules/kubernetes/)** | Oracle Kubernetes Engine | OKE Clusters, Node Pools, Virtual Nodes, Auto-scaling | [📖 README](modules/kubernetes/README.md) |
| **[Load Balancer](modules/load-balancer/)** | Balanceamento de Carga | LB Flexível, Backend Sets, Listeners, SSL/TLS, Health Checks | [📖 README](modules/load-balancer/README.md) |
| **[Network](modules/network/)** | VCN e Conectividade | VCN, Subnets, Gateways, Route Tables, Security Lists | [📖 README](modules/network/README.md) |
| **[Block Storage](modules/storage/block-storage/)** | Block Volumes | Block Volumes, Volume Groups, Backups | [📖 README](modules/storage/block-storage/README.md) |
| **[File Storage](modules/storage/file-storage/)** | File Storage (NFS) | File Systems, Mount Targets, Export Sets, NFS Exports | [📖 README](modules/storage/file-storage/README.md) |
| **[WAF](modules/storage/waf/)** | Web Application Firewall | WAF Policies, Protection Rules, Rate Limiting | [📖 README](modules/storage/waf/README.md) |

## Início Rápido

### Pré-requisitos

Certifique-se de ter instalado:

- ✅ **Terraform** >= 1.0 ([Download](https://www.terraform.io/downloads))
- ✅ **OCI CLI** ([Instalação](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm))
- ✅ **Git** ([Download](https://git-scm.com/downloads))

### Configuração Inicial

#### 1. Configure OCI CLI

```bash
oci setup config
```

Isso criará `~/.oci/config` com suas credenciais.

#### 2. Clone o Repositório

```bash
git clone https://github.com/your-org/terraform-oci-modules.git
cd terraform-oci-modules
```

#### 3. Explore a Estrutura

```bash
# Ver módulos disponíveis
ls -la modules/

# Ver exemplos
ls -la environments/

# Ler documentação de um módulo
cat modules/network/README.md
```

## Como Adicionar Novo Cliente

### Opção 1: Stack Básico (Web + Database)

```bash
# 1. Copie o template básico
cd environments
cp -r client-example stark-corp
cd stark-corp

# 2. Configure as credenciais
vim terraform.tfvars

# 3. Ajuste as configurações do cliente
# Edite: cliente_name, ssh_public_key, common_tags

# 4. Inicialize e aplique
terraform init
terraform plan
terraform apply
```

### Opção 2: Stack Completo (All Modules)

```bash
# 1. Copie o template completo
cd environments
cp -r full-stack-example stark-corp-k8s
cd stark-corp-k8s

# 2. Configure conforme necessário
vim terraform.tfvars

# 3. Inicialize e aplique
terraform init
terraform plan
terraform apply
```

### Opção 3: Stack Customizado

```bash
# 1. Crie novo diretório
cd environments
mkdir meu-cliente-custom
cd meu-cliente-custom

# 2. Crie main.tf usando apenas módulos necessários
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# Use apenas os módulos que precisa
module "network" {
  source = "../../modules/network"
  # configurações...
}

module "compute" {
  source = "../../modules/compute"
  # configurações...
}
EOF

# 3. Crie variables.tf e terraform.tfvars
# 4. terraform init && terraform apply
```

## Exemplos de Uso

### Exemplo 1: Web Application Simples

**Stack:** Network + Compute + Load Balancer + Database

```hcl
# environments/web-app/main.tf
module "network" {
  source         = "../../modules/network"
  compartment_id = var.compartment_id
  vcn_name       = "${var.cliente_name}-vcn"
  # ...
}

module "web_servers" {
  source         = "../../modules/compute"
  instance_count = 3
  subnet_id      = module.network.public_subnet_ids[0]
  # ...
}

module "load_balancer" {
  source = "../../modules/load-balancer"
  # ...
}

module "database" {
  source                     = "../../modules/database"
  create_autonomous_database = true
  # ...
}
```

**[Ver exemplo completo](environments/client-example/README.md)**

**Tempo de provisionamento:** ~15 minutos  
**Custo estimado:** ~$200-500/mês

### Exemplo 2: Plataforma de Microservices

**Stack:** Network + OKE + Container Registry + Database

```hcl
# environments/microservices/main.tf
module "kubernetes" {
  source       = "../../modules/kubernetes"
  cluster_name = "${var.cliente_name}-oke"
  node_pools   = [...]
  # ...
}

module "container_registry" {
  source       = "../../modules/container-registry"
  repositories = [...]
  # ...
}

module "database" {
  source                     = "../../modules/database"
  create_autonomous_database = true
  # ...
}
```

**[Ver exemplo completo](environments/full-stack-example/main.tf)**

**Tempo de provisionamento:** ~20-30 minutos  
**Custo estimado:** ~$500-1000/mês

### Exemplo 3: File Storage para Aplicações

**Stack:** Network + File Storage + Compute

```hcl
module "file_storage" {
  source = "../../modules/storage/file-storage"
  
  file_storage_system = {
    name = "app-shared-storage"
    mount_targets = [...]
    export_sets = [...]
    storage_exports = [...]
  }
}
```

**[Ver exemplo completo](modules/storage/file-storage/README.md)**

## Arquiteturas de Referência

### Three-Tier Web Application

```
┌────────────────────────────────────────────────────────────┐
│                          Internet                          │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │Load Balancer │ (Público)
                  └──────┬───────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
      ┌──────────┐              ┌──────────┐
      │Web Server│              │Web Server│ (Subnet Pública)
      └────┬─────┘              └────┬─────┘
           │                         │
           └────────────┬────────────┘
                        ▼
                  ┌──────────┐
                  │App Server│ (Subnet Privada)
                  └────┬─────┘
                       │
                       ▼
               ┌──────────────┐
               │   Database   │ (Subnet Privada)
               └──────────────┘
```

**Componentes:**
- Load Balancer público
- 2-3 Web Servers (subnet pública)
- 2-3 App Servers (subnet privada)
- Autonomous Database (subnet privada)

**Módulos:** Network, Compute, Load Balancer, Database  
**Custo estimado:** ~$300-600/mês

### Kubernetes Microservices Platform

```
┌────────────────────────────────────────────────────────────┐
│                          Internet                          │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Ingress Controller  │
              └──────────┬───────────┘
                         │
              ┌──────────▼───────────┐
              │    OKE Cluster       │
              │  ┌────────────────┐  │
              │  │  Microservice  │  │
              │  │  Microservice  │  │
              │  │  Microservice  │  │
              │  └────────┬───────┘  │
              └───────────┼──────────┘
                          │
              ┌───────────┴──────────┐
              │                      │
         ┌────▼─────┐         ┌─────▼────┐
         │Container │         │ Database │
         │ Registry │         └──────────┘
         └──────────┘
```

**Componentes:**
- OKE Cluster (3-5 nodes)
- Container Registry (OCIR)
- Autonomous Database
- File Storage (opcional)

**Módulos:** Network, Kubernetes, Container Registry, Database  
**Custo estimado:** ~$600-1200/mês

### High Availability Multi-Region

```
Region 1 (Primary)              Region 2 (DR)
┌─────────────────┐            ┌─────────────────┐
│      VCN        │            │      VCN        │
│  ┌───────────┐  │            │  ┌───────────┐  │
│  │ Resources │  │◄──────────►│  │ Resources │  │
│  └───────────┘  │  Peering   │  └───────────┘  │
│  ┌───────────┐  │            │  ┌───────────┐  │
│  │ Database  │  │   Data     │  │ Database  │  │
│  │ (Primary) │  ├───Guard───►│  │(Standby)  │  │
│  └───────────┘  │            │  └───────────┘  │
└─────────────────┘            └─────────────────┘
```

**Componentes:**
- VCN em cada região
- Compute instances replicados
- Data Guard para database
- VCN Peering ou FastConnect

**Módulos:** Network (x2), Compute (x2), Database (com Data Guard)  
**Custo estimado:** ~$1500-3000/mês

## Segurança

### Security Features Implementadas

✅ **Network Isolation**
- Subnets públicas e privadas separadas
- Security Lists configuradas por padrão
- NSG support para controle granular

✅ **Access Control**
- IAM Policies com least privilege
- Dynamic Groups para serviços
- MFA recomendado para usuários

✅ **Data Protection**
- Private endpoints para databases
- Encryption at-rest (automático)
- KMS encryption (opcional)
- SSL/TLS para load balancers

✅ **Secrets Management**
- Variáveis sensíveis marcadas
- Integração com OCI Vault (recomendado)
- Nunca commit credentials

### Security Checklist

Antes de ir para produção:

- [ ] Credenciais OCI não estão no código
- [ ] `terraform.tfvars` está no `.gitignore`
- [ ] SSH público desabilitado em produção (`allow_public_ssh = false`)
- [ ] Databases usam private endpoints
- [ ] Load Balancers usam HTTPS com certificados válidos
- [ ] Backups automáticos habilitados
- [ ] Tags de compliance aplicadas
- [ ] Network Security Groups configurados
- [ ] Logs centralizados habilitados
- [ ] Monitoring e alertas configurados
- [ ] Policies IAM seguem least privilege
- [ ] Senhas fortes (min 14 chars, complexidade)

### Exemplo de .gitignore

```gitignore
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
.terraform/
.terraform.lock.hcl
crash.log
override.tf
override.tf.json

# OCI Credentials
.oci/
*.pem
*.key

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
```

## Melhores Práticas

### 1. Organização de Código

```
✅ FAZER:
- Um módulo por responsabilidade
- Módulos reutilizáveis e parametrizados
- README completo para cada módulo
- Exemplos de uso documentados

❌ NÃO FAZER:
- Hardcode de valores
- Módulos muito específicos
- Falta de documentação
- Secrets no código
```

### 2. Nomenclatura

```hcl
# ✅ BOM
resource "oci_core_vcn" "main" {
  display_name = "${var.cliente_name}-vcn"
}

resource "oci_core_instance" "web" {
  display_name = "${var.cliente_name}-web-${count.index + 1}"
}

# ❌ RUIM
resource "oci_core_vcn" "vcn1" {
  display_name = "my-vcn"
}
```

### 3. Versionamento

```hcl
# Sempre especifique versões
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"  # Permite 5.x.x
    }
  }
}
```

### 4. State Management

```hcl
# Use remote backend para produção
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "cliente-prod/terraform.tfstate"
    region                      = "sa-saopaulo-1"
    endpoint                    = "https://namespace.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

### 5. Tags Obrigatórias

```hcl
common_tags = {
  Environment  = "Production"      # Obrigatória
  ManagedBy    = "Terraform"       # Obrigatória
  CostCenter   = "IT"              # Obrigatória
  Owner        = "Platform Team"   # Recomendada
  Project      = "MyApp"           # Recomendada
  Compliance   = "PCI-DSS"         # Se aplicável
  DataClass    = "Confidential"    # Se aplicável
}
```

## CI/CD

### GitHub Actions

```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
    paths:
      - 'environments/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Configure OCI
        run: |
          mkdir -p ~/.oci
          echo "${{ secrets.OCI_CONFIG }}" > ~/.oci/config
          echo "${{ secrets.OCI_KEY }}" > ~/.oci/key.pem
          chmod 600 ~/.oci/key.pem
      
      - name: Terraform Init
        run: |
          cd environments/production
          terraform init
      
      - name: Terraform Plan
        run: |
          cd environments/production
          terraform plan -out=tfplan
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: |
          cd environments/production
          terraform apply tfplan
```

### GitLab CI

```yaml
variables:
  TF_VERSION: "1.5.0"

stages:
  - validate
  - plan
  - apply

before_script:
  - wget -O terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
  - unzip terraform.zip
  - chmod +x terraform
  - mv terraform /usr/local/bin/

validate:
  stage: validate
  script:
    - cd environments/production
    - terraform init -backend=false
    - terraform validate

plan:
  stage: plan
  script:
    - cd environments/production
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - environments/production/tfplan

apply:
  stage: apply
  script:
    - cd environments/production
    - terraform init
    - terraform apply tfplan
  when: manual
  only:
    - main
```

## Troubleshooting

### Problemas Comuns

#### 1. Erro: "Service limit exceeded"

**Solução:**
```bash
# Verificar limites
oci limits resource-availability get \
  --compartment-id <id> \
  --service-name compute

# Solicitar aumento no OCI Console
# Governance → Limits, Quotas and Usage → Request Limit Increase
```

#### 2. Erro: "Subnet has no available IPs"

**Solução:**
```hcl
# Use CIDR maior
variable "private_subnet_cidrs" {
  default = ["10.0.10.0/23"]  # 512 IPs ao invés de 256
}

# Ou crie mais subnets
```

#### 3. Erro: "Authentication failed"

**Solução:**
```bash
# Verifique configuração OCI
oci setup repair-file-permissions --file ~/.oci/config

# Teste autenticação
oci iam region list

# Verifique fingerprint
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | \
  openssl md5 -c
```

#### 4. State Lock Error

**Solução:**
```bash
# Forçar unlock (cuidado!)
terraform force-unlock <lock-id>

# Melhor: Use remote backend com lock
```

#### 5. Terraform Apply muito lento

**Solução:**
```bash
# Use paralelismo
terraform apply -parallelism=20

# Separe em múltiplos applies
terraform apply -target=module.network
terraform apply -target=module.compute
terraform apply
```

### Debug Mode

```bash
# Habilitar logs detalhados
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

terraform plan
terraform apply

# Desabilitar
unset TF_LOG
unset TF_LOG_PATH
```

## Estimativa de Custos

### Por Arquitetura

| Arquitetura | Componentes | Custo/Mês (USD) |
|-------------|-------------|-----------------|
| **Dev/Test** | 2 VMs pequenas, 1 DB small | ~$100-200 |
| **Web App Básica** | LB + 3 VMs + ADB | ~$300-500 |
| **Microservices** | OKE + OCIR + ADB | ~$600-1000 |
| **Enterprise HA** | Multi-AD, Data Guard | ~$1500-3000 |

### Por Módulo (Estimativas)

| Módulo | Recurso | Custo/Mês |
|--------|---------|-----------|
| **Compute** | VM.Standard.E4.Flex (2 OCPU, 32GB) | ~$70 |
| **Compute** | BM.Standard.E4.128 | ~$2400 |
| **Network** | VCN + Gateways | Grátis |
| **Load Balancer** | Flexible (10-100 Mbps) | ~$20-30 |
| **Database** | Autonomous DB (1 OCPU) | ~$180 |
| **Database** | MySQL (2 OCPU, 32GB) | ~$90 |
| **Kubernetes** | OKE (3 nodes E4.Flex 2 OCPU) | ~$210 |
| **Storage** | Block Volume (50GB) | ~$2.5 |
| **Storage** | File Storage (100GB) | ~$17 |

### Calculadora de Custos

Use a [OCI Cost Estimator](https://www.oracle.com/cloud/cost-estimator.html) para estimativas precisas.


## Suporte

- **Documentação OCI**: https://docs.oracle.com/iaas
- **Terraform OCI Provider**: https://registry.terraform.io/providers/oracle/oci
- **Issues**: [GitHub Issues](https://github.com/your-org/terraform-oci-modules/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/terraform-oci-modules/discussions)

## Roadmap

### Em Desenvolvimento
- [ ] Módulo de Object Storage
- [ ] Módulo de Functions (Serverless)
- [ ] Módulo de API Gateway
- [ ] Módulo de Bastion Service

### Planejado
- [ ] Módulo de Streaming
- [ ] Módulo de Data Science
- [ ] Módulo de Monitoring & Logging
- [ ] Templates por indústria (E-commerce, FinTech, Healthcare)
- [ ] Terraform Cloud/Enterprise integration
- [ ] Compliance frameworks (PCI-DSS, HIPAA, SOC2)

### Melhorias
- [ ] Testes automatizados (Terratest)
- [ ] Pre-commit hooks
- [ ] Auto-generated documentation
- [ ] Cost estimation automation
- [ ] Drift detection

## Changelog

### v1.0.0 (2025)
- ✅ Módulo IAM completo
- ✅ Módulo Network completo
- ✅ Módulo Compute completo
- ✅ Módulo Load Balancer completo
- ✅ Módulo Database completo (ADB, MySQL, PostgreSQL)
- ✅ Módulo Container Registry completo
- ✅ Módulo Kubernetes (OKE) completo
- ✅ Módulo File Storage completo
- ✅ Documentação completa para todos os módulos
- ✅ Exemplos de uso (client-example e full-stack-example)
- ✅ Estrutura multi-cliente

**Desenvolvido com ❤️ para simplificar o provisionamento de infraestrutura OCI**
