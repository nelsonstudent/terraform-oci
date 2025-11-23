# Environment: Cliente Exemplo

Este é um ambiente de exemplo que demonstra como utilizar os módulos Terraform para provisionar uma infraestrutura completa na OCI para um novo cliente.

## 📋 Arquitetura Provisionada

```
┌─────────────────────────────────────────────────────────────────┐
│                    VCN (10.0.0.0/16)                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 Internet Gateway                         │   │
│  └─────────────────────┬────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼────────────────────────────────────┐   │
│  │            Load Balancer (Público)                       │   │
│  │            IP: XXX.XXX.XXX.XXX                           │   │
│  └─────────────────────┬────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼────────────────────────────────────┐   │
│  │         Public Subnets (10.0.1.0/24, 10.0.2.0/24)        │   │
│  │                                                          │   │
│  │  ┌──────────────┐          ┌──────────────┐              │   │
│  │  │ Web Server 1 │          │ Web Server 2 │              │   │
│  │  │  (Public IP) │          │  (Public IP) │              │   │
│  │  └──────────────┘          └──────────────┘              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                        │                                        │
│                        │                                        │
│  ┌─────────────────────▼────────────────────────────────────┐   │
│  │      Private Subnets (10.0.10.0/24, 10.0.11.0/24)        │   │
│  │                                                          │   │
│  │  ┌──────────────┐  ┌──────────────┐                      │   │
│  │  │ App Server 1 │  │ App Server 2 │                      │   │
│  │  │ + Data Vol.  │  │ + Data Vol.  │                      │   │
│  │  └──────────────┘  └──────────────┘                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼────────────────────────────────────┐   │
│  │                 NAT Gateway                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Recursos Provisionados

### Network
- **1x VCN** com CIDR 10.0.0.0/16
- **2x Subnets Públicas** (para Load Balancer e Web Servers)
- **2x Subnets Privadas** (para App Servers)
- **1x Internet Gateway** (acesso à internet)
- **1x NAT Gateway** (saída para subnets privadas)
- **1x Service Gateway** (acesso aos serviços Oracle)
- **Route Tables** configuradas
- **Security Lists** com regras de firewall

### Compute
- **2x Web Servers** (VM.Standard.E4.Flex)
  - 1 OCPU, 16 GB RAM cada
  - 50 GB boot volume
  - IPs públicos
  - Apache/Nginx instalado via cloud-init
  
- **2x App Servers** (VM.Standard.E4.Flex)
  - 2 OCPUs, 32 GB RAM cada
  - 100 GB boot volume
  - 200 GB data volume adicional
  - IPs privados apenas
  - Java instalado via cloud-init

### Load Balancer
- **1x Load Balancer Flexível**
  - Bandwidth: 10-100 Mbps (ajustável)
  - Health check configurado
  - Round-robin policy
  - Listener HTTP na porta 80

## 📁 Estrutura de Arquivos

```
cliente-exemplo/
├── main.tf           # Configuração principal e chamada dos módulos
├── variables.tf      # Definição de todas as variáveis
├── terraform.tfvars  # Valores das variáveis (CUSTOMIZAR AQUI)
├── outputs.tf        # Outputs da infraestrutura
└── README.md         # Este arquivo
```

## 🚀 Como Usar para um Novo Cliente

### Passo 1: Copiar o Template

```bash
# Copie este diretório para o novo cliente
cp -r environments/cliente-exemplo environments/novo-cliente

cd environments/novo-cliente
```

### Passo 2: Configurar Credenciais OCI

Edite o arquivo `terraform.tfvars` e configure as credenciais:

```hcl
# Configurações OCI
region           = "sa-saopaulo-1"  # ou us-ashburn-1, etc.
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxx"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
compartment_id   = "ocid1.compartment.oc1..aaaaaaaaxxxxxx"
```

### Passo 3: Customizar Configurações do Cliente

No mesmo arquivo `terraform.tfvars`, ajuste conforme necessário:

```hcl
# Nome do Cliente (prefixo para todos os recursos)
cliente_name = "acme-corp"

# Ajustar CIDRs se necessário
vcn_cidr_blocks = ["10.0.0.0/16"]

# Ajustar quantidade de servidores
web_instance_count = 2
app_instance_count = 3

# Ajustar recursos (OCPUs e memória)
web_instance_ocpus  = 2
web_instance_memory = 32

# Sua chave SSH pública
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."

# Tags
common_tags = {
  Environment = "Production"
  Cliente     = "ACME Corp"
  ManagedBy   = "Terraform"
  CostCenter  = "TI"
}
```

### Passo 4: Inicializar Terraform

```bash
terraform init
```

### Passo 5: Revisar o Plano

```bash
terraform plan -out=tfplan

# Revise cuidadosamente o que será criado
```

### Passo 6: Aplicar

```bash
terraform apply tfplan
```

### Passo 7: Acessar a Infraestrutura

Após o apply, o Terraform mostrará os outputs:

```bash
terraform output connection_info
terraform output infrastructure_summary
```

## 📊 Outputs Disponíveis

### Network Outputs
```bash
terraform output vcn_id
terraform output public_subnet_ids
terraform output private_subnet_ids
```

### Compute Outputs
```bash
terraform output web_server_public_ips
terraform output app_server_private_ips
```

### Load Balancer Outputs
```bash
terraform output load_balancer_public_ip
terraform output load_balancer_ip_addresses
```

### Resumo Completo
```bash
terraform output infrastructure_summary
```

### Informações de Conexão
```bash
terraform output connection_info
```

## 🔧 Customizações Comuns

### Alterar Número de Servidores

No `terraform.tfvars`:
```hcl
web_instance_count = 3  # Aumentar para 3 web servers
app_instance_count = 4  # Aumentar para 4 app servers
```

### Aumentar Recursos das Instâncias

No `terraform.tfvars`:
```hcl
# Web Servers mais potentes
web_instance_ocpus  = 2
web_instance_memory = 32

# App Servers mais potentes
app_instance_ocpus  = 4
app_instance_memory = 64
```

### Mudar Shape das Instâncias

No `terraform.tfvars`:
```hcl
web_instance_shape = "VM.Standard.E5.Flex"  # AMD mais novo
app_instance_shape = "VM.Standard3.Flex"    # Intel
```

### Adicionar Volume de Dados Maior

No `terraform.tfvars`:
```hcl
app_data_volume_size = 500  # 500 GB ao invés de 200 GB
```

### Aumentar Bandwidth do Load Balancer

No `terraform.tfvars`:
```hcl
lb_min_bandwidth = 100
lb_max_bandwidth = 400
```

### Customizar Subnets

No `terraform.tfvars`:
```hcl
public_subnets = [
  {
    name      = "dmz-subnet-1"
    cidr      = "10.0.1.0/24"
    dns_label = "dmz1"
  },
  {
    name      = "dmz-subnet-2"
    cidr      = "10.0.2.0/24"
    dns_label = "dmz2"
  },
  {
    name      = "dmz-subnet-3"
    cidr      = "10.0.3.0/24"
    dns_label = "dmz3"
  }
]
```

### Customizar Cloud-Init Scripts

No `terraform.tfvars`:
```hcl
web_user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Configurações customizadas
cat > /etc/nginx/conf.d/custom.conf <<'NGINX'
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:8080;
    }
}
NGINX

systemctl restart nginx
EOF
```

## 🔒 Segurança

### SSH Keys
- **NUNCA** commite chaves privadas no repositório
- Use `terraform.tfvars` (já no `.gitignore`) para chaves públicas
- Considere usar SSH Certificate Authority

### Secrets
- Use OCI Vault para secrets sensíveis
- Não coloque senhas em `terraform.tfvars`
- Use variáveis de ambiente quando possível:
  ```bash
  export TF_VAR_database_password="senha-segura"
  ```

### Network Security
- Por padrão, SSH público está **desabilitado** (`allow_public_ssh = false`)
- Use Bastion Host para acesso SSH aos servidores
- App Servers não têm IP público

### Tags de Compliance
```hcl
common_tags = {
  Environment    = "Production"
  Cliente        = "ACME Corp"
  ManagedBy      = "Terraform"
  CostCenter     = "TI"
  DataClass      = "Confidential"
  Compliance     = "PCI-DSS"
  BackupPolicy   = "Daily"
}
```

## 🎨 Personalizações Avançadas

### Adicionar HTTPS ao Load Balancer

1. Adicione certificados no `main.tf`:
```hcl
module "load_balancer" {
  # ... outras configurações ...
  
  certificates = [
    {
      certificate_name   = "ssl-cert"
      ca_certificate     = file("${path.module}/certs/ca.pem")
      private_key        = file("${path.module}/certs/private.key")
      public_certificate = file("${path.module}/certs/public.crt")
    }
  ]
  
  listeners = [
    {
      name                     = "https"
      default_backend_set_name = "web-backend"
      port                     = 443
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 300
      }
      ssl_configuration = {
        certificate_name        = "ssl-cert"
        verify_peer_certificate = false
        verify_depth            = 5
      }
    }
  ]
}
```

### Adicionar Database (Autonomous Database)

Crie novo módulo ou adicione recursos:
```hcl
resource "oci_database_autonomous_database" "db" {
  compartment_id           = var.compartment_id
  db_name                  = "${var.cliente_name}db"
  display_name             = "${var.cliente_name}-db"
  admin_password           = var.db_admin_password
  db_workload              = "OLTP"
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  subnet_id                = module.network.private_subnet_ids[0]
}
```

### Adicionar Backup Policy

```hcl
resource "oci_core_volume_backup_policy_assignment" "app_backup" {
  count     = var.app_instance_count
  asset_id  = module.app_servers.boot_volume_ids[count.index]
  policy_id = data.oci_core_volume_backup_policies.default_backup_policy.volume_backup_policies[0].id
}
```

## 📈 Escalabilidade

### Scale-Up (Vertical)
Aumente recursos das instâncias existentes:
```bash
# Edite terraform.tfvars
web_instance_ocpus = 4
web_instance_memory = 64

terraform apply
```

### Scale-Out (Horizontal)
Aumente número de instâncias:
```bash
# Edite terraform.tfvars
web_instance_count = 5

terraform apply
```

## 🔄 Manutenção

### Atualizar Imagens do SO
```bash
# Terraform recreará as instâncias com nova imagem
terraform taint 'module.web_servers.oci_core_instance.this[0]'
terraform apply
```

### Drenar Servidor do Load Balancer

Edite `main.tf` temporariamente:
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

## 🗑️ Destruição de Recursos

### Destruir Tudo
```bash
terraform destroy
```

### Destruir Apenas Compute
```bash
terraform destroy -target=module.web_servers
terraform destroy -target=module.app_servers
```

### Destruir Apenas Load Balancer
```bash
terraform destroy -target=module.load_balancer
```

## 📝 Checklist de Deploy

- [ ] Credenciais OCI configuradas em `terraform.tfvars`
- [ ] Nome do cliente definido
- [ ] Chave SSH pública configurada
- [ ] CIDRs revisados (sem conflitos)
- [ ] Quantidade de recursos definida
- [ ] Cloud-init scripts revisados
- [ ] Tags configuradas
- [ ] `terraform init` executado
- [ ] `terraform plan` revisado
- [ ] `terraform apply` executado
- [ ] Outputs validados
- [ ] Teste de conectividade realizado
- [ ] Documentação atualizada

## 🆘 Troubleshooting

### Erro: "Service limit exceeded"
- Solicite aumento de limites no OCI Console
- Ou reduza quantidade de recursos

### Erro: "Subnet não tem IPs disponíveis"
- Use CIDR maior para as subnets
- Ou reduza número de instâncias

### Instâncias não conseguem acessar internet
- Verifique se NAT Gateway está criado
- Confirme route tables estão corretas

### Load Balancer marca backends como unhealthy
- Verifique se web servers estão rodando
- Confirme health check endpoint existe
- Revise Security Lists/NSGs

### Não consigo fazer SSH
- Para web servers: Verifique se `assign_public_ip = true`
- Para app servers: Use jump host/bastion
- Confirme Security Lists permitem porta 22

## 📞 Suporte

Para questões sobre:
- **Módulos Terraform**: Consulte READMEs dos módulos individuais
- **OCI**: [Documentação oficial](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- **Terraform OCI Provider**: [Provider docs](https://registry.terraform.io/providers/oracle/oci/latest/docs)

## 📄 Licença

MIT
