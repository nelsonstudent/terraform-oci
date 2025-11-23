# Módulo Compute - OCI Terraform

Este módulo cria instâncias de computação (VMs e Bare Metal) na Oracle Cloud Infrastructure (OCI), incluindo configuração de rede, armazenamento e agentes de monitoramento.

## Recursos Criados

- **Compute Instances** - Instâncias VM ou Bare Metal
- **Boot Volumes** - Volumes de inicialização
- **Block Volumes** - Volumes de dados adicionais (opcional)
- **Volume Attachments** - Anexação de volumes às instâncias
- **VNICs** - Interfaces de rede

## Uso Básico

```hcl
module "web_servers" {
  source = "../../modules/compute"
  
  compartment_id      = "ocid1.compartment.oc1..aaaaaaaaxxxxxx"
  availability_domain = "xYzW:SA-SAOPAULO-1-AD-1"
  
  instance_name  = "web-server"
  instance_count = 2
  instance_shape = "VM.Standard.E4.Flex"
  
  instance_shape_config_ocpus         = 2
  instance_shape_config_memory_in_gbs = 32
  
  subnet_id        = "ocid1.subnet.oc1..aaaaaaaaxxxxxx"
  assign_public_ip = true
  ssh_public_key   = file("~/.ssh/id_rsa.pub")
  
  boot_volume_size_in_gbs = 100
  
  tags = {
    Environment = "Production"
    Role        = "WebServer"
  }
}
```

## Variáveis Principais

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|-------------|
| `compartment_id` | ID do compartment | `string` | - | Sim |
| `availability_domain` | Availability domain para criar a instância | `string` | - | Sim |
| `instance_name` | Nome da instância | `string` | - | Sim |
| `instance_count` | Número de instâncias a criar | `number` | `1` | Não |
| `instance_shape` | Shape da instância | `string` | `"VM.Standard.E4.Flex"` | Não |
| `subnet_id` | ID da subnet | `string` | - | Sim |
| `ssh_public_key` | Chave SSH pública | `string` | - | Sim |

### Variáveis de Shape (Flex Shapes)

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `instance_shape_config_ocpus` | Número de OCPUs | `number` | `1` |
| `instance_shape_config_memory_in_gbs` | Memória em GB | `number` | `16` |

### Variáveis de Imagem

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `instance_os` | Sistema operacional | `string` | `"Oracle Linux"` |
| `instance_os_version` | Versão do SO | `string` | `"8"` |
| `image_name_filter` | Filtro regex para nome da imagem | `string` | `".*"` |
| `source_image_id` | ID da imagem customizada | `string` | `null` |

### Variáveis de Rede

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `assign_public_ip` | Atribuir IP público | `bool` | `false` |
| `hostname_label` | Label do hostname | `string` | `null` |
| `private_ips` | Lista de IPs privados | `list(string)` | `null` |
| `nsg_ids` | IDs de Network Security Groups | `list(string)` | `[]` |
| `skip_source_dest_check` | Desabilitar verificação source/dest | `bool` | `false` |

### Variáveis de Armazenamento

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `boot_volume_size_in_gbs` | Tamanho do boot volume | `number` | `50` |
| `create_block_volume` | Criar block volume adicional | `bool` | `false` |
| `block_volume_size_in_gbs` | Tamanho do block volume | `number` | `50` |
| `block_volume_vpus_per_gb` | Performance do volume (VPUs) | `number` | `10` |
| `block_volume_attachment_type` | Tipo de attachment | `string` | `"paravirtualized"` |
| `preserve_boot_volume` | Preservar boot volume após destruir | `bool` | `false` |

### Variáveis de Configuração

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `user_data` | Script cloud-init | `string` | `null` |
| `custom_metadata` | Metadata customizado | `map(string)` | `{}` |
| `disable_monitoring` | Desabilitar monitoramento | `bool` | `false` |
| `is_live_migration_preferred` | Preferir live migration | `bool` | `true` |
| `recovery_action` | Ação de recuperação | `string` | `"RESTORE_INSTANCE"` |

## Outputs

| Nome | Descrição |
|------|-----------|
| `instance_ids` | IDs das instâncias criadas |
| `instance_public_ips` | IPs públicos das instâncias |
| `instance_private_ips` | IPs privados das instâncias |
| `instance_names` | Nomes das instâncias |
| `boot_volume_ids` | IDs dos boot volumes |
| `block_volume_ids` | IDs dos block volumes adicionais |
| `block_volume_attachment_ids` | IDs dos attachments de block volumes |

## Exemplos de Uso

### Exemplo 1: Web Server com IP Público

```hcl
module "web_server" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "web-server"
  instance_shape = "VM.Standard.E4.Flex"
  
  instance_shape_config_ocpus         = 1
  instance_shape_config_memory_in_gbs = 16
  
  subnet_id        = module.network.public_subnet_ids[0]
  assign_public_ip = true
  ssh_public_key   = var.ssh_public_key
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Welcome</h1>" > /var/www/html/index.html
  EOF
  
  tags = {
    Role = "WebServer"
  }
}
```

### Exemplo 2: Application Server Privado com Volume de Dados

```hcl
module "app_server" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "app-server"
  instance_count = 3
  instance_shape = "VM.Standard.E4.Flex"
  
  instance_shape_config_ocpus         = 4
  instance_shape_config_memory_in_gbs = 64
  
  subnet_id        = module.network.private_subnet_ids[0]
  assign_public_ip = false
  ssh_public_key   = var.ssh_public_key
  
  boot_volume_size_in_gbs = 100
  
  # Volume adicional para dados
  create_block_volume         = true
  block_volume_size_in_gbs    = 500
  block_volume_vpus_per_gb    = 20  # Alta performance
  block_volume_attachment_type = "paravirtualized"
  
  tags = {
    Role = "AppServer"
    Tier = "Application"
  }
}
```

### Exemplo 3: Bare Metal com Imagem Customizada

```hcl
module "bare_metal" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "bare-metal-db"
  instance_shape = "BM.Standard.E4.128"
  
  # Usar imagem customizada
  source_image_id = "ocid1.image.oc1..aaaaaaaaxxxxxx"
  
  subnet_id        = module.network.private_subnet_ids[0]
  assign_public_ip = false
  ssh_public_key   = var.ssh_public_key
  
  boot_volume_size_in_gbs = 256
  
  # Desabilitar live migration para bare metal
  is_live_migration_preferred = false
  
  tags = {
    Role = "Database"
    Type = "BareMetal"
  }
}
```

### Exemplo 4: Múltiplas Instâncias com IPs Privados Fixos

```hcl
module "app_cluster" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "app-node"
  instance_count = 3
  instance_shape = "VM.Standard.E4.Flex"
  
  instance_shape_config_ocpus         = 2
  instance_shape_config_memory_in_gbs = 32
  
  subnet_id  = module.network.private_subnet_ids[0]
  private_ips = ["10.0.10.10", "10.0.10.11", "10.0.10.12"]
  
  hostname_label = "appnode"
  ssh_public_key = var.ssh_public_key
  
  tags = {
    Cluster = "AppCluster"
  }
}
```

## Shapes Disponíveis

### VM Standard Shapes
- **VM.Standard.E4.Flex** - AMD (1-64 OCPUs, 1-1024 GB RAM)
- **VM.Standard.E5.Flex** - AMD (1-94 OCPUs, 1-1504 GB RAM)
- **VM.Standard3.Flex** - Intel (1-32 OCPUs, 1-512 GB RAM)
- **VM.Standard.A1.Flex** - ARM Ampere (1-80 OCPUs, 1-512 GB RAM)

### Bare Metal Shapes
- **BM.Standard.E4.128** - AMD (128 OCPUs, 2048 GB RAM)
- **BM.Standard.E5.192** - AMD (192 OCPUs, 2304 GB RAM)
- **BM.Standard3.64** - Intel (64 OCPUs, 1024 GB RAM)

## Cloud-Init (user_data)

O módulo suporta cloud-init através da variável `user_data`. Exemplo:

```hcl
user_data = <<-EOF
  #!/bin/bash
  
  # Atualizar sistema
  yum update -y
  
  # Instalar pacotes
  yum install -y docker-ce git
  
  # Configurar serviços
  systemctl start docker
  systemctl enable docker
  
  # Criar usuário
  useradd -m -s /bin/bash appuser
  
  # Montar volume de dados (se existir)
  if [ -b /dev/oracleoci/oraclevdb ]; then
    mkfs.xfs /dev/oracleoci/oraclevdb
    mkdir -p /data
    mount /dev/oracleoci/oraclevdb /data
    echo "/dev/oracleoci/oraclevdb /data xfs defaults,_netdev 0 2" >> /etc/fstab
  fi
EOF
```

## Block Volumes

### Performance Levels (VPUs per GB)

| VPUs/GB | IOPS/GB | Throughput/GB | Uso Recomendado |
|---------|---------|---------------|-----------------|
| 0 | 2 | 240 KB/s | Arquivos, backups |
| 10 | 60 | 480 KB/s | Uso geral (padrão) |
| 20 | 75 | 600 KB/s | Alta performance |
| 30-120 | 100+ | 800+ KB/s | Ultra performance |

### Attachment Types

- **paravirtualized** - Melhor performance, recomendado (padrão)
- **iscsi** - Compatibilidade com sistemas antigos

## Network Security Groups (NSG)

Para melhor controle de segurança, use NSGs:

```hcl
module "app_server" {
  source = "../../modules/compute"
  
  # ... outras configurações ...
  
  nsg_ids = [
    oci_core_network_security_group.app_nsg.id,
    oci_core_network_security_group.monitoring_nsg.id
  ]
}
```

## Recuperação e Alta Disponibilidade

### Recovery Actions

- **RESTORE_INSTANCE** - Reinicia a instância automaticamente (padrão)
- **STOP_INSTANCE** - Para a instância para investigação manual

### Live Migration

```hcl
is_live_migration_preferred = true  # Mínimo downtime durante manutenção
```

## Monitoramento

O módulo habilita agentes de monitoramento por padrão:

```hcl
disable_monitoring = false  # Coleta métricas para OCI Monitoring
disable_management = false  # Permite gerenciamento via OCI
```

## Troubleshooting

### Instância não inicia
- Verifique se a imagem é compatível com o shape
- Confirme que o subnet tem conectividade adequada
- Revise os logs do cloud-init: `sudo cat /var/log/cloud-init-output.log`

### Não consegue conectar via SSH
- Verifique Security Lists/NSGs permitem porta 22
- Confirme que a chave SSH está correta
- Para instâncias públicas, verifique se `assign_public_ip = true`

### Block volume não aparece no SO
- Aguarde alguns minutos após a criação
- Execute: `sudo iscsiadm -m session -P 3` (para iscsi)
- Para paravirtualized: `ls -la /dev/oracleoci/`
- Use cloud-init para formatar e montar automaticamente

### Shape não disponível
- Verifique limites de serviço no compartment
- Tente outro availability domain
- Considere requisitar aumento de limite

## Requisitos

- Terraform >= 1.0
- Provider OCI >= 5.0
- Permissões necessárias no compartment
- Chave SSH válida

## Licença

MIT
