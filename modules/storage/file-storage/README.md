# Submódulo File Storage - OCI Terraform

Este submódulo cria e configura File Storage Service (FSS) na Oracle Cloud Infrastructure (OCI), incluindo file systems, mount targets, export sets e exports para compartilhamento NFS.

## Recursos Criados

- **File System** - Sistema de arquivos NFS compartilhado
- **Mount Target** - Endpoint de rede para acesso ao file system
- **Export Set** - Conjunto de configurações de export
- **Storage Export** - Export NFS com permissões e opções

## Arquitetura do Módulo

```
file-storage/
├── main.tf                   # Orquestração dos submódulos
├── variables.tf              # Variáveis do módulo principal
├── outputs.tf                # Outputs consolidados
├── file-system/              # Submódulo: File System
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── mount-target/             # Submódulo: Mount Target
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── export-set/               # Submódulo: Export Set
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── export/                   # Submódulo: Storage Export
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Uso Básico

```hcl
module "file_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "production"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "shared-storage"
    
    # Mount Targets
    mount_targets = [
      {
        display_name        = "mt-app-servers"
        subnet_id           = var.private_subnet_id
        hostname_label      = "nfs"
        ip_address          = "10.0.10.100"  # Opcional
        nsg_ids             = []
      }
    ]
    
    # Export Sets
    export_sets = [
      {
        display_name      = "export-set-1"
        mount_target_name = "mt-app-servers"
        max_fs_stat_bytes = 23843202333
        max_fs_stat_files = 223442
      }
    ]
    
    # Storage Exports
    storage_exports = [
      {
        export_set_name = "export-set-1"
        path            = "/shared"
        export_options = {
          source                         = "10.0.10.0/24"
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      }
    ]
  }
  
  common_tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
  
  tag_cost_tracker = "CostTracking.CostCenter"
}
```

## Variáveis

### Variáveis Principais

| Nome | Descrição | Tipo | Obrigatório |
|------|-----------|------|-------------|
| `compartment_id` | ID do compartment | `string` | Sim |
| `compartment_name` | Nome do compartment | `string` | Sim |
| `vcn_id` | ID da VCN | `string` | Sim |
| `file_storage_system` | Configuração completa do file storage | `object` | Sim |
| `common_tags` | Tags comuns | `map(string)` | Não |
| `tag_cost_tracker` | Tag para rastreamento de custos | `string` | Não |

### Estrutura do file_storage_system

```hcl
{
  name = string  # Nome do file system
  
  mount_targets = list(object({
    display_name   = string         # Nome do mount target
    subnet_id      = string         # ID da subnet
    hostname_label = string         # Label DNS (ex: "nfs")
    ip_address     = string         # IP privado (opcional)
    nsg_ids        = list(string)   # Network Security Groups
  }))
  
  export_sets = list(object({
    display_name      = string  # Nome do export set
    mount_target_name = string  # Nome do mount target associado
    max_fs_stat_bytes = number  # Max bytes reportados (opcional)
    max_fs_stat_files = number  # Max files reportados (opcional)
  }))
  
  storage_exports = list(object({
    export_set_name = string  # Nome do export set
    path            = string  # Path do export (ex: "/shared")
    export_options = object({
      source                         = string  # CIDR permitido
      access                         = string  # READ_WRITE ou READ_ONLY
      identity_squash                = string  # NONE, ROOT, ALL
      anonymous_uid                  = number  # UID para anonymous
      anonymous_gid                  = number  # GID para anonymous
      require_privileged_source_port = bool    # Requer porta < 1024
    })
  }))
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| `file_system_info` | Informações do file system |
| `export_set_info` | Informações dos export sets |

## Exemplos de Uso

### Exemplo 1: File Storage Simples para Aplicação

```hcl
module "app_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "app-prod"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "app-shared-files"
    
    mount_targets = [
      {
        display_name   = "app-mount-target"
        subnet_id      = var.private_subnet_id
        hostname_label = "appnfs"
        ip_address     = null  # IP automático
        nsg_ids        = [var.app_nsg_id]
      }
    ]
    
    export_sets = [
      {
        display_name      = "app-export-set"
        mount_target_name = "app-mount-target"
        max_fs_stat_bytes = 23843202333
        max_fs_stat_files = 223442
      }
    ]
    
    storage_exports = [
      {
        export_set_name = "app-export-set"
        path            = "/app/shared"
        export_options = {
          source                         = "10.0.10.0/24"  # Subnet dos app servers
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      }
    ]
  }
  
  common_tags = {
    Application = "MyApp"
    Tier        = "Storage"
  }
  
  tag_cost_tracker = "CostTracking.Project"
}
```

### Exemplo 2: Storage com Múltiplos Mount Targets (Multi-AD)

```hcl
module "ha_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "production"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "ha-shared-storage"
    
    # Mount target em cada AD para alta disponibilidade
    mount_targets = [
      {
        display_name   = "mt-ad1"
        subnet_id      = var.subnet_ad1_id
        hostname_label = "nfs1"
        ip_address     = "10.0.1.100"
        nsg_ids        = [var.storage_nsg_id]
      },
      {
        display_name   = "mt-ad2"
        subnet_id      = var.subnet_ad2_id
        hostname_label = "nfs2"
        ip_address     = "10.0.2.100"
        nsg_ids        = [var.storage_nsg_id]
      }
    ]
    
    # Export set para cada mount target
    export_sets = [
      {
        display_name      = "export-set-ad1"
        mount_target_name = "mt-ad1"
        max_fs_stat_bytes = 23843202333
        max_fs_stat_files = 223442
      },
      {
        display_name      = "export-set-ad2"
        mount_target_name = "mt-ad2"
        max_fs_stat_bytes = 23843202333
        max_fs_stat_files = 223442
      }
    ]
    
    # Exports para cada export set
    storage_exports = [
      {
        export_set_name = "export-set-ad1"
        path            = "/shared"
        export_options = {
          source                         = "10.0.1.0/24"
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      },
      {
        export_set_name = "export-set-ad2"
        path            = "/shared"
        export_options = {
          source                         = "10.0.2.0/24"
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      }
    ]
  }
  
  common_tags = {
    Environment     = "Production"
    HighAvailability = "true"
  }
  
  tag_cost_tracker = "CostTracking.CostCenter"
}
```

### Exemplo 3: Storage com Controles de Acesso Restritivos

```hcl
module "secure_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "secure-prod"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "secure-data"
    
    mount_targets = [
      {
        display_name   = "secure-mt"
        subnet_id      = var.secure_subnet_id
        hostname_label = "securenfs"
        ip_address     = "10.0.20.50"
        nsg_ids        = [var.secure_nsg_id]
      }
    ]
    
    export_sets = [
      {
        display_name      = "secure-export-set"
        mount_target_name = "secure-mt"
        max_fs_stat_bytes = 10737418240  # 10GB limit
        max_fs_stat_files = 100000
      }
    ]
    
    storage_exports = [
      {
        export_set_name = "secure-export-set"
        path            = "/secure/data"
        export_options = {
          source                         = "10.0.20.0/28"  # Apenas subnet específica
          access                         = "READ_ONLY"     # Somente leitura
          identity_squash                = "ROOT"          # Squash root para segurança
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = true           # Requer porta privilegiada
        }
      }
    ]
  }
  
  common_tags = {
    Environment       = "Production"
    DataClassification = "Confidential"
    Compliance        = "PCI-DSS"
  }
  
  tag_cost_tracker = "CostTracking.SecurityTeam"
}
```

### Exemplo 4: Storage para Kubernetes (OKE)

```hcl
module "k8s_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "oke-prod"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "k8s-persistent-storage"
    
    mount_targets = [
      {
        display_name   = "oke-mount-target"
        subnet_id      = var.oke_subnet_id
        hostname_label = "k8snfs"
        ip_address     = null
        nsg_ids        = [var.oke_worker_nsg_id]
      }
    ]
    
    export_sets = [
      {
        display_name      = "k8s-export-set"
        mount_target_name = "oke-mount-target"
        max_fs_stat_bytes = 107374182400  # 100GB
        max_fs_stat_files = 1000000
      }
    ]
    
    storage_exports = [
      {
        export_set_name = "k8s-export-set"
        path            = "/k8s/pv"
        export_options = {
          source                         = "10.0.30.0/24"  # OKE worker subnet
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      }
    ]
  }
  
  common_tags = {
    Environment = "Production"
    Platform    = "Kubernetes"
    ManagedBy   = "Terraform"
  }
  
  tag_cost_tracker = "CostTracking.Platform"
}
```

### Exemplo 5: Storage com Múltiplos Exports

```hcl
module "multi_export_storage" {
  source = "../../modules/storage/file-storage"
  
  compartment_id   = var.compartment_id
  compartment_name = "shared-services"
  vcn_id           = var.vcn_id
  
  file_storage_system = {
    name = "multi-tenant-storage"
    
    mount_targets = [
      {
        display_name   = "shared-mt"
        subnet_id      = var.shared_subnet_id
        hostname_label = "sharednfs"
        ip_address     = "10.0.100.100"
        nsg_ids        = []
      }
    ]
    
    export_sets = [
      {
        display_name      = "shared-export-set"
        mount_target_name = "shared-mt"
        max_fs_stat_bytes = 53687091200  # 50GB
        max_fs_stat_files = 500000
      }
    ]
    
    # Múltiplos exports com diferentes permissões
    storage_exports = [
      # Export para aplicação 1 (RW)
      {
        export_set_name = "shared-export-set"
        path            = "/app1"
        export_options = {
          source                         = "10.0.10.0/24"
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 1001
          anonymous_gid                  = 1001
          require_privileged_source_port = false
        }
      },
      # Export para aplicação 2 (RW)
      {
        export_set_name = "shared-export-set"
        path            = "/app2"
        export_options = {
          source                         = "10.0.11.0/24"
          access                         = "READ_WRITE"
          identity_squash                = "NONE"
          anonymous_uid                  = 1002
          anonymous_gid                  = 1002
          require_privileged_source_port = false
        }
      },
      # Export compartilhado (RO)
      {
        export_set_name = "shared-export-set"
        path            = "/shared"
        export_options = {
          source                         = "10.0.0.0/16"  # Toda VCN
          access                         = "READ_ONLY"
          identity_squash                = "ALL"
          anonymous_uid                  = 65534
          anonymous_gid                  = 65534
          require_privileged_source_port = false
        }
      }
    ]
  }
  
  common_tags = {
    Environment = "Shared"
    Purpose     = "Multi-tenant"
  }
  
  tag_cost_tracker = "CostTracking.SharedServices"
}
```

## Export Options

### Access Types

| Tipo | Descrição |
|------|-----------|
| `READ_WRITE` | Leitura e escrita completas |
| `READ_ONLY` | Apenas leitura |

### Identity Squash

| Tipo | Descrição | Uso |
|------|-----------|-----|
| `NONE` | Sem squash, mantém UIDs originais | Desenvolvimento, confiança total |
| `ROOT` | Squash apenas root (UID 0) | Produção padrão, segurança moderada |
| `ALL` | Squash todos os usuários | Máxima segurança, acesso público |

### Anonymous UID/GID

UIDs/GIDs comuns:
- `65534` - nobody/nogroup (padrão)
- `1000-9999` - UIDs de aplicação
- Deve corresponder aos usuários no cliente NFS

## Conectividade de Rede

### Security Lists

```hcl
# Permitir NFS
resource "oci_core_security_list" "nfs_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "NFS Security List"
  
  # Ingress - NFS
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "10.0.10.0/24"
    
    tcp_options {
      min = 2048
      max = 2050
    }
  }
  
  # Ingress - NFS mount
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "10.0.10.0/24"
    
    tcp_options {
      min = 111
      max = 111
    }
  }
  
  # Egress
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
```

### Network Security Groups (NSG)

```hcl
# NSG para File Storage
resource "oci_core_network_security_group" "fss_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "FSS NSG"
}

# Regras de entrada
resource "oci_core_network_security_group_security_rule" "fss_ingress_tcp" {
  network_security_group_id = oci_core_network_security_group.fss_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = "10.0.10.0/24"
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 2048
      max = 2050
    }
  }
}
```

## Montagem no Cliente

### Linux

```bash
# Instalar NFS client
sudo yum install -y nfs-utils  # Oracle Linux/RHEL
# ou
sudo apt-get install -y nfs-common  # Ubuntu/Debian

# Criar ponto de montagem
sudo mkdir -p /mnt/shared

# Montar
sudo mount 10.0.10.100:/shared /mnt/shared

# Verificar
df -h | grep shared

# Mount permanente (/etc/fstab)
echo "10.0.10.100:/shared /mnt/shared nfs defaults,nofail,nosuid,resvport 0 0" | sudo tee -a /etc/fstab

# Testar fstab
sudo mount -a
```

### Kubernetes (OKE)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fss-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.0.30.100
    path: "/k8s/pv"
  mountOptions:
    - nfsvers=3
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fss-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  volumeName: fss-pv
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: fss-pvc
```

## Performance

### Métricas de Performance

- **Throughput**: Até 2.4 GB/s por mount target
- **IOPS**: Milhares de operações por segundo
- **Latência**: Baixa latência (< 1ms típico)

### Otimização

```bash
# Mount options recomendadas
mount -t nfs -o rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport nfs-server:/path /mnt

# Opções:
# - rsize/wsize: Tamanho do buffer de leitura/escrita
# - hard: Retry infinito (vs soft)
# - timeo: Timeout em décimos de segundo
# - retrans: Número de retransmissões
# - noresvport: Não usar porta reservada (< 1024)
```

## Custos

### Modelo de Preços

- **Armazenamento**: ~R$1.65 por GB/mês (metered)
- **Performance**: Standard
- **Max IOPS**: 5000
- **Max Throughput(Gbps)**: 1
- **Snapshots**: Incluídos
- **Tráfego**: Sem custo adicional (mesma região)

### Otimização de Custos

1. **Use apenas o necessário** - Pague pelo usado
2. **Snapshots** - Automáticos e inclusos
3. **Lifecycle management** - Delete dados antigos
4. **Monitoring** - Monitore uso real

## Monitoramento

### Métricas OCI

```bash
# Via OCI CLI
oci monitoring metric-data summarize-metrics-data \
  --compartment-id <compartment-id> \
  --namespace oci_filestorage

# Métricas disponíveis:
# - FileSystemUsedBytes
# - FileSystemUsedPercent
# - MountTargetConnections
```

### Alarmes

```hcl
resource "oci_monitoring_alarm" "fss_usage" {
  display_name = "FSS High Usage"
  compartment_id = var.compartment_id
  
  metric_compartment_id = var.compartment_id
  namespace = "oci_filestorage"
  query = "FileSystemUsedPercent[1m].mean() > 80"
  
  severity = "WARNING"
  destinations = [var.notification_topic_id]
}
```

## Segurança

### Melhores Práticas

✅ **Use subnets privadas** para mount targets  
✅ **Configure NSGs** para controle granular  
✅ **Identity squash** apropriado (ROOT para produção)  
✅ **Restrinja source CIDRs** ao mínimo necessário  
✅ **Use encryption em trânsito** (NFSv4 Kerberos)  
✅ **Snapshots regulares** para backup  

### Encryption

- **At-rest**: Criptografia automática (Oracle-managed keys)
- **In-transit**: NFSv4 com Kerberos (opcional)

## Troubleshooting

### Mount falha: "access denied"

**Solução**:
```bash
# Verificar export options (source CIDR)
# Verificar security lists/NSGs
# Testar conectividade
telnet <mount-target-ip> 2049
```

### Permission denied ao escrever

**Solução**:
```bash
# Verificar identity_squash
# Verificar UIDs/GIDs no cliente
id
# Ajustar anonymous_uid/gid se necessário
```

### Performance lenta

**Solução**:
```bash
# Verificar mount options
mount | grep nfs
# Usar rsize/wsize maiores
# Verificar latência de rede
ping <mount-target-ip>
```

### Stale file handle

**Solução**:
```bash
# Remontar
sudo umount /mnt/shared
sudo mount 10.0.10.100:/shared /mnt/shared
```

## Recursos Adicionais

- [File Storage Documentation](https://docs.oracle.com/en-us/iaas/Content/File/home.htm)
- [NFS Best Practices](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/nfsbestpractices.htm)
- [Mount Target Configuration](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/managingmounttargets.htm)
