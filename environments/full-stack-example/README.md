# Ambiente: Full-Stack Example

Este ambiente provisiona uma infraestrutura completa e robusta na OCI, projetada para uma aplicação full-stack moderna. A arquitetura inclui rede segura, servidores de frontend e backend, um banco de dados gerenciado, um registro de contêiner e um cluster Kubernetes (OKE).

## 📋 Arquitetura Provisionada

O diagrama abaixo ilustra a arquitetura que será criada:
┌──────────────────────────────────────────────────────────────────────────────────┐
│                                VCN (10.0.0.0/16)                                 │
│                                                                                  │
│   ┌─────────────────────────┐                            ┌───────────────────┐   │
│   │    Internet Gateway     │◄───────────┐               │   Service Gateway │   │
│   └───────────┬─────────────┘            │               └─────────┬─────────┘   │
│               │                          │                         │             │
│   ┌───────────▼──────────────────────────▼─────────────────────────▼─────────┐   │
│   │                 Public Subnet (10.0.1.0/24)                              │   │
│   │                                                                          │   │
│   │   ┌─────────────────┐   ┌─────────────────┐   ┌────────────────────────┐ │   │
│   │   │   Web Server 1  │   │   Web Server 2  │   │ OKE API Endpoint (Pub) │ │   │
│   │   └───────▲─────────┘   └───────▲─────────┘   └────────────────────────┘ │   │
│   │           └──────────────┬──────┘                                        │   │
│   │               ┌──────────▼──────────┐                                    │   │
│   │               │    Load Balancer    │                                    │   │
│   │               └─────────────────────┘                                    │   │
│   └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│   ┌──────────────────────────────────────────────────────────────────────────┐   │
│   │  Private Subnets (10.0.10.0/24, 10.0.11.0/24)           ┌──────────────┐ │   │
│   │                                                         │ NAT Gateway  │◄──┘ │
│   │   ┌─────────────────┐   ┌─────────────────┐             └───────▲──────┘ │   │
│   │   │   App Server 1  │   │   App Server 2  │                              │   │
│   │   └─────────────────┘   └─────────────────┘                              │   │
│   │                                                                          │   |  
│   │   ┌─────────────────────────────────────────────────────────┐            │   │
│   │   │         OKE Node Pool (Worker Nodes Privados)           │            │   │
│   │   └─────────────────────────────────────────────────────────┘            │   │
│   │                                                                          │   │
│   │   ┌─────────────────────────────────────────────────────────┐            │   │
│   │   │         Autonomous Database (Endpoint Privado)          │            │   │
│   │   └─────────────────────────────────────────────────────────┘            │   │
│   └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘


## 🎯 Recursos Provisionados

*   **IAM**:
    *   Grupos `admins` e `developers` para controle de acesso.
    *   Políticas de permissão que seguem o princípio do menor privilégio.

*   **Rede**:
    *   1 **VCN** com sub-redes públicas e privadas.
    *   **Internet Gateway** para acesso público, **NAT Gateway** para saídas seguras e **Service Gateway** para acesso otimizado aos serviços OCI.

*   **Load Balancer**:
    *   1 **Load Balancer flexível** para distribuir o tráfego entre os servidores web.

*   **Compute**:
    *   **Servidores Web**: Instâncias na sub-rede pública para servir o frontend.
    *   **Servidores de Aplicação**: Instâncias na sub-rede privada para o backend.

*   **Database**:
    *   1 **Autonomous Database (OLTP)** com endpoint privado para máxima segurança.

*   **Container Registry (OCIR)**:
    *   Repositórios para as imagens Docker do `frontend` e `backend-api`.

*   **Kubernetes (OKE)**:
    *   1 **Cluster Kubernetes Gerenciado** com um *node pool* de workers na sub-rede privada, pronto para orquestrar os contêineres da aplicação.

## 📁 Estrutura de Arquivos

full-stack-example/
├── main.tf           # Lógica principal que orquestra a criação dos módulos.
├── variables.tf      # Definição de todas as variáveis de entrada.
├── terraform.tfvars  # Valores das variáveis (único arquivo a ser editado).
└── README.md         # Este guia.

## 🚀 Como Implantar a Infraestrutura

### Passo 1: Pré-requisitos

1.  Instale o [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli ).
2.  Configure a [CLI da OCI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm ) com suas credenciais, gerando um par de chaves de API.

### Passo 2: Configurar as Variáveis 

Edite o arquivo `terraform.tfvars` e preencha com suas informações específicas.

```hcl
# Suas credenciais e identificadores da OCI
region              = "sa-saopaulo-1"
tenancy_ocid        = "ocid1.tenancy.oc1..xxxxxxxxxx"
user_ocid           = "ocid1.user.oc1..xxxxxxxxxx"
fingerprint         = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path    = "~/.oci/oci_api_key.pem"
compartment_id      = "ocid1.compartment.oc1..xxxxxxxxxx"
availability_domain = "Uocm:SA-SAOPAULO-1-AD-1"

# Sua chave SSH pública para acesso às VMs
ssh_public_key = "ssh-rsa AAAA..."

# Senha para o Autonomous Database (use uma senha forte!)
db_admin_password = "SuaSenhaForteParaOBanco#2025"

# Tags e nome do projeto (pode customizar se desejar)
project_name = "fstack-prod"
common_tags = {
  Environment = "Production"
  Project     = "FullStackApp"
  ManagedBy   = "Terraform"
}
```

### Passo 3: Inicializar o Terraform
Este comando baixa os provedores e módulos necessários.

```hcl
terraform init
```

### Passo 4: Planejar e Execução

O Terrafomr irá mostrar todos os recursos que serão criados. Revise está saída cuidadosamente:

```hcl
terraform plan -out=tfplan
```

### Passo 5: Aplicar o Plano

Este comando provisionará toda a infraestrutura na sua conta OCI. A execução pode levar vários minutos.

```hcl
terraform apply "tfplan"
```

📊 Acessando os Recursos Criados
Após a conclusão, o Terraform exibirá os outputs com informações importantes, como IPs e IDs. Você também pode consultá-los a qualquer momento com:

# IP público do Load Balancer (ponto de entrada da aplicação)
terraform output load_balancer_public_ip

# IPs públicos dos servidores web (para acesso SSH direto, se necessário)
terraform output web_server_public_ips

# Endpoint da API do cluster Kubernetes
terraform output kubernetes_api_endpoint

# Instruções para configurar o kubectl e acessar o cluster
terraform output kubernetes_connection_instructions

### 🔧 Customização
Para alterar a quantidade ou o tamanho dos recursos, basta editar as variáveis correspondentes no arquivo terraform.tfvars e aplicar novamente.

Exemplo: Aumentar o número de servidores de aplicação para 3.

1. Edite terraform.tfvars:

# ... outras variáveis ...
app_instance_count = 3
# ...

2. Execute terraform plan e terraform apply. O Terraform detectará a mudança e criará apenas a nova instância.

### 🗑️ Destruindo a Infraestrutura

Para remover todos os recursos criados por este ambiente e evitar custos, execute o comando abaixo. Atenção: esta ação é irreversível.

```hcl
terraform destroy
```
