# Módulo Database - OCI Terraform

Este módulo cria e configura bancos de dados gerenciados na Oracle Cloud Infrastructure (OCI), incluindo Autonomous Database, MySQL Database Service e PostgreSQL Database Service.

## Recursos Criados

- **Autonomous Database** - Oracle Database totalmente gerenciado e auto-otimizado
- **MySQL Database System** - MySQL gerenciado com alta disponibilidade
- **PostgreSQL Database System** - PostgreSQL gerenciado e escalável
- **Backups** - Backups automáticos e manuais

## Uso Básico

### Autonomous Database (Oracle)

```hcl
module "autonomous_db" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id
  
  display_name   = "my-adb"
  admin_password = var.db_password  # Mínimo 12 caracteres
  
  # Autonomous Database
  create_autonomous_database   = true
  db_name                      = "myadb"  # Apenas letras e números
  db_workload                  = "OLTP"   # OLTP, DW, AJD, APEX
  
  # Recursos
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  
  # Features
  is_auto_scaling_enabled             = true
  is_auto_scaling_for_storage_enabled = true
  is_free_tier                        = false
  license_model                       = "LICENSE_INCLUDED"
  
  # Network
  use_private_endpoint = true
  
  tags = {
    Environment = "Production"
    Type        = "Database"
  }
}
```

### MySQL Database

```hcl
module "mysql_db" {
  source = "../../modules/database"
  
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  subnet_id           = var.private_subnet_id
  
  display_name   = "my-mysql"
  admin_password = var.db_password
  
  # MySQL
  create_mysql         = true
  mysql_shape          = "MySQL.VM.Standard.E3.1.8GB"
  mysql_admin_username = "admin"
  mysql_data_storage_gb = 50
  
  # Backup
  mysql_backup_enabled         = true
  mysql_backup_retention_days  = 7
  mysql_pitr_enabled          = true
  
  # High Availability
  mysql_is_highly_available = true
  
  tags = {
    Environment = "Production"
    Type        = "MySQL"
  }
}
```

### PostgreSQL Database

```hcl
module "postgresql_db" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id
  
  display_name   = "my-postgresql"
  admin_password = var.db_password
  
  # PostgreSQL
  create_postgresql        = true
  postgresql_version       = "14"
  postgresql_shape         = "PostgreSQL.VM.Standard.E4.Flex.2.32GB"
  postgresql_admin_username = "postgres"
  
  # Cluster configuration
  postgresql_instance_count    = 3
  postgresql_instance_ocpus    = 2
  postgresql_instance_memory_gb = 32
  
  # Storage
  postgresql_regional_storage = true
  
  tags = {
    Environment = "Production"
    Type        = "PostgreSQL"
  }
}
```

## Variáveis Principais

### Comuns a Todos os Tipos

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|-------------|
| `compartment_id` | ID do compartment | `string` | - | Sim |
| `subnet_id` | ID da subnet (privada recomendado) | `string` | - | Sim |
| `display_name` | Nome de exibição do database | `string` | - | Sim |
| `admin_password` | Senha do administrador (min. 12 caracteres) | `string` | - | Sim |

### Autonomous Database

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `create_autonomous_database` | Criar Autonomous Database | `bool` | `false` |
| `db_name` | Nome do database (apenas alfanumérico) | `string` | - |
| `db_workload` | Tipo de workload | `string` | `"OLTP"` |
| `cpu_core_count` | Número de OCPUs | `number` | `1` |
| `data_storage_size_in_tbs` | Storage em TB | `number` | `1` |
| `is_auto_scaling_enabled` | Auto-scaling de CPU | `bool` | `false` |
| `is_auto_scaling_for_storage_enabled` | Auto-scaling de storage | `bool` | `false` |
| `is_free_tier` | Usar Always Free | `bool` | `false` |
| `license_model` | Modelo de licença | `string` | `"LICENSE_INCLUDED"` |
| `is_data_guard_enabled` | Habilitar Data Guard (standby) | `bool` | `false` |
| `use_private_endpoint` | Usar endpoint privado | `bool` | `true` |

### MySQL

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `create_mysql` | Criar MySQL Database | `bool` | `false` |
| `mysql_shape` | Shape do MySQL | `string` | `"MySQL.VM.Standard.E3.1.8GB"` |
| `mysql_admin_username` | Username do admin | `string` | `"admin"` |
| `mysql_data_storage_gb` | Storage em GB | `number` | `50` |
| `mysql_backup_enabled` | Backups automáticos | `bool` | `true` |
| `mysql_backup_retention_days` | Dias de retenção | `number` | `7` |
| `mysql_pitr_enabled` | Point-in-Time Recovery | `bool` | `false` |
| `mysql_is_highly_available` | Alta disponibilidade | `bool` | `false` |

### PostgreSQL

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `create_postgresql` | Criar PostgreSQL Database | `bool` | `false` |
| `postgresql_version` | Versão do PostgreSQL | `string` | `"14"` |
| `postgresql_shape` | Shape do PostgreSQL | `string` | `"PostgreSQL.VM.Standard.E4.Flex.2.32GB"` |
| `postgresql_admin_username` | Username do admin | `string` | `"postgres"` |
| `postgresql_instance_count` | Número de instâncias | `number` | `1` |
| `postgresql_instance_ocpus` | OCPUs por instância | `number` | `2` |
| `postgresql_instance_memory_gb` | Memória por instância | `number` | `32` |
| `postgresql_regional_storage` | Storage regional | `bool` | `true` |

## Outputs

| Nome | Descrição |
|------|-----------|
| `autonomous_database_id` | ID do Autonomous Database |
| `autonomous_database_connection_strings` | Connection strings do ADB |
| `autonomous_database_connection_urls` | URLs de conexão |
| `mysql_id` | ID do MySQL Database System |
| `mysql_endpoints` | Endpoints do MySQL |
| `mysql_ip_address` | IP address do MySQL |
| `postgresql_id` | ID do PostgreSQL Database System |
| `postgresql_instances` | Instâncias do PostgreSQL |
| `connection_info` | Informações de conexão consolidadas |

## Exemplos de Uso

### Exemplo 1: Autonomous Database para OLTP (Transacional)

```hcl
module "transactional_db" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id
  
  display_name   = "prod-oltp-db"
  admin_password = var.db_password
  
  create_autonomous_database = true
  db_name                    = "proddb"
  db_workload                = "OLTP"
  
  # Produção: recursos adequados
  cpu_core_count           = 2
  data_storage_size_in_tbs = 2
  
  # Auto-scaling para picos de carga
  is_auto_scaling_enabled             = true
  is_auto_scaling_for_storage_enabled = true
  
  # Alta disponibilidade com Data Guard
  is_data_guard_enabled = true
  
  # Segurança: endpoint privado
  use_private_endpoint = true
  
  tags = {
    Environment = "Production"
    Criticality = "High"
    Backup      = "Daily"
  }
}
```

### Exemplo 2: Data Warehouse com Autonomous Database

```hcl
module "data_warehouse" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id
  
  display_name   = "analytics-dw"
  admin_password = var.dw_password
  
  create_autonomous_database = true
  db_name                    = "analyticsdb"
  db_workload                = "DW"  # Data Warehouse
  
  # DW: mais CPU e storage
  cpu_core_count           = 4
  data_storage_size_in_tbs = 5
  
  is_auto_scaling_enabled = true
  license_model          = "BRING_YOUR_OWN_LICENSE"
  
  use_private_endpoint = true
  
  tags = {
    Environment = "Production"
    Purpose     = "Analytics"
  }
}
```

### Exemplo 3: MySQL com Alta Disponibilidade

```hcl
module "mysql_ha" {
  source = "../../modules/database"
  
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  subnet_id           = var.private_subnet_id
  
  display_name   = "prod-mysql"
  admin_password = var.mysql_password
  
  create_mysql         = true
  mysql_shape          = "MySQL.VM.Standard.E4.8.128GB"
  mysql_admin_username = "dbadmin"
  mysql_data_storage_gb = 500
  
  # Alta Disponibilidade
  mysql_is_highly_available = true
  
  # Backups robustos
  mysql_backup_enabled        = true
  mysql_backup_retention_days = 30
  mysql_pitr_enabled         = true  # Point-in-Time Recovery
  
  # Janelas de manutenção
  mysql_backup_window_start      = "03:00"
  mysql_maintenance_window_start = "SUNDAY 04:00"
  
  tags = {
    Environment = "Production"
    Database    = "MySQL"
    HA          = "Enabled"
  }
}
```

### Exemplo 4: PostgreSQL Cluster

```hcl
module "postgresql_cluster" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id
  
  display_name   = "prod-postgresql-cluster"
  admin_password = var.pg_password
  
  create_postgresql        = true
  postgresql_version       = "14"
  postgresql_admin_username = "pgadmin"
  
  # Cluster com 3 instâncias
  postgresql_instance_count    = 3
  postgresql_instance_ocpus    = 4
  postgresql_instance_memory_gb = 64
  
  # Storage otimizado
  postgresql_shape            = "PostgreSQL.VM.Standard.E4.Flex.4.64GB"
  postgresql_regional_storage = true
  postgresql_storage_type     = "OCI_OPTIMIZED_STORAGE"
  
  nsg_ids = [var.database_nsg_id]
  
  tags = {
    Environment = "Production"
    Database    = "PostgreSQL"
    Cluster     = "3-nodes"
  }
}
```

### Exemplo 5: Autonomous Database Always Free

```hcl
module "free_tier_db" {
  source = "../../modules/database"
  
  compartment_id = var.compartment_id
  subnet_id      = var.public_subnet_id  # Always Free precisa de subnet pública
  
  display_name   = "dev-free-db"
  admin_password = var.db_password
  
  create_autonomous_database = true
  db_name                    = "devdb"
  db_workload                = "OLTP"
  
  # Always Free tier
  is_free_tier             = true
  cpu_core_count           = 1
  data_storage_size_in_tbs = 0.02  # 20GB
  
  # Free tier não suporta algumas features
  is_auto_scaling_enabled   = false
  is_data_guard_enabled     = false
  use_private_endpoint      = false
  
  tags = {
    Environment = "Development"
    Tier        = "Free"
  }
}
```

## Tipos de Workload do Autonomous Database

| Workload | Descrição | Uso Recomendado |
|----------|-----------|-----------------|
| **OLTP** | Online Transaction Processing | Aplicações transacionais, e-commerce, APIs |
| **DW** | Data Warehouse | Analytics, relatórios, BI |
| **AJD** | Autonomous JSON Database | Aplicações com JSON, NoSQL-like |
| **APEX** | Application Express | Low-code application development |

## Shapes Disponíveis

### MySQL Shapes

| Shape | OCPUs | RAM (GB) | Network | Uso |
|-------|-------|----------|---------|-----|
| `MySQL.VM.Standard.E3.1.8GB` | 1 | 8 | 1 Gbps | Desenvolvimento |
| `MySQL.VM.Standard.E3.2.16GB` | 2 | 16 | 2 Gbps | Pequeno/Médio |
| `MySQL.VM.Standard.E4.4.64GB` | 4 | 64 | 4 Gbps | Produção |
| `MySQL.VM.Standard.E4.8.128GB` | 8 | 128 | 8 Gbps | Alta performance |

### PostgreSQL Shapes

| Shape | OCPUs | RAM (GB) | Uso |
|-------|-------|----------|-----|
| `PostgreSQL.VM.Standard.E4.Flex.1.16GB` | 1 | 16 | Desenvolvimento |
| `PostgreSQL.VM.Standard.E4.Flex.2.32GB` | 2 | 32 | Pequeno/Médio |
| `PostgreSQL.VM.Standard.E4.Flex.4.64GB` | 4 | 64 | Produção |
| `PostgreSQL.VM.Standard.E4.Flex.8.128GB` | 8 | 128 | Alta performance |

## Conectividade

### Autonomous Database

```bash
# Connection string está no output
terraform output autonomous_database_connection_strings

# Baixar wallet
oci db autonomous-database generate-wallet \
  --autonomous-database-id <adb-id> \
  --file wallet.zip \
  --password <wallet-password>

# Conectar com SQL*Plus
sqlplus admin@<connection-string>
```

### MySQL

```bash
# Obter IP do output
terraform output mysql_ip_address

# Conectar
mysql -h <mysql-ip> -P 3306 -u admin -p
```

### PostgreSQL

```bash
# Obter informações das instâncias
terraform output postgresql_instances

# Conectar
psql -h <instance-ip> -p 5432 -U postgres -d postgres
```

## Segurança

### Melhores Práticas

1. **Sempre use subnets privadas** para databases de produção
2. **Habilite private endpoints** para Autonomous Database
3. **Configure Network Security Groups** para controle granular
4. **Use senhas fortes** (mínimo 12 caracteres, complexidade)
5. **Habilite backups automáticos** com retenção adequada
6. **Configure Data Guard** para databases críticos
7. **Use KMS encryption** para dados sensíveis

### Senha do Admin

```hcl
# NUNCA coloque senha no código
# Use variável sensível
variable "db_password" {
  type      = string
  sensitive = true
}

# Ou use OCI Vault
data "oci_secrets_secretbundle" "db_password" {
  secret_id = var.vault_secret_id
}
```

## Backups e Recuperação

### Autonomous Database

- **Backups automáticos**: Retidos por 60 dias (padrão)
- **Manual backups**: Controle total da retenção
- **Point-in-Time Recovery**: Restaurar para qualquer ponto nos últimos 60 dias

### MySQL

```hcl
mysql_backup_enabled        = true
mysql_backup_retention_days = 30      # 1-35 dias
mysql_pitr_enabled         = true     # Point-in-Time Recovery
mysql_backup_window_start  = "03:00"  # Horário de menor carga
```

### PostgreSQL

- **Automated backups**: Integrado com OCI
- **Snapshots**: Via OCI Console ou API
- **Regional replication**: Para disaster recovery

## Escalabilidade

### Autonomous Database

```hcl
# Auto-scaling automático
is_auto_scaling_enabled             = true  # CPU até 3x
is_auto_scaling_for_storage_enabled = true  # Storage até 3x

# Manual scaling (sem downtime)
cpu_core_count           = 4  # Altere e apply
data_storage_size_in_tbs = 5  # Apenas aumenta
```

### MySQL

```hcl
# Alta disponibilidade (3 ADs)
mysql_is_highly_available = true

# Scale-up: Mude o shape
mysql_shape = "MySQL.VM.Standard.E4.8.128GB"
```

### PostgreSQL

```hcl
# Scale-out: Adicione instâncias
postgresql_instance_count = 5

# Scale-up: Aumente recursos por instância
postgresql_instance_ocpus    = 8
postgresql_instance_memory_gb = 128
```

## Manutenção

### Windows de Manutenção

```hcl
# Autonomous Database
maintenance_schedule_type = "REGULAR"  # ou "EARLY"

# MySQL
mysql_maintenance_window_start = "SUNDAY 04:00"

# PostgreSQL
# Gerenciado pela OCI em horários de baixa carga
```

## Otimização de Custos

### Dicas para Economizar

1. **Always Free Tier**
   - 2x Autonomous Database (20GB cada)
   - Ideal para dev/test

2. **Auto-scaling**
   - Pague apenas quando necessário
   - Retorna ao mínimo automaticamente

3. **Right-sizing**
   - Comece pequeno
   - Escale baseado em métricas

4. **Bring Your Own License (BYOL)**
   - Até 50% de economia
   - Se já tem licenças Oracle

5. **Development Environments**
   - Use shapes menores
   - Desabilite HA em dev/test

## Monitoramento

### Métricas Disponíveis

- **CPU Utilization**
- **Storage Usage**
- **Active Connections**
- **Query Performance**
- **Backup Status**

### Integração

```hcl
# OCI Monitoring (automático)
# Métricas disponíveis em:
# OCI Console → Observability → Monitoring

# Alarmes
resource "oci_monitoring_alarm" "db_cpu" {
  display_name = "DB High CPU"
  # ...
}
```

## Troubleshooting

### Database não inicia

**Autonomous Database:**
- Verifique subnet tem conectividade
- Confirme admin_password atende requisitos
- Revise limites de serviço

**MySQL/PostgreSQL:**
- Verifique availability domain disponível
- Confirme shape existe na região
- Revise logs: OCI Console → Database → Logs

### Não consegue conectar

1. **Verifique Security Lists/NSGs**
   ```bash
   # MySQL: Porta 3306
   # PostgreSQL: Porta 5432
   ```

2. **Private Endpoint**
   - Conexão deve vir de dentro da VCN
   - Use bastion ou VPN

3. **Whitelist IPs (ADB)**
   ```hcl
   whitelisted_ips = ["10.0.0.0/16"]
   ```

### Performance Issues

- **Habilite auto-scaling**
- **Revise queries lentas** (AWR/Performance Insights)
- **Considere upgrade de shape**
- **Adicione read replicas** (MySQL HA)

## Recursos Adicionais

- [Autonomous Database Docs](https://docs.oracle.com/en/cloud/paas/autonomous-database/)
- [MySQL Database Service](https://docs.oracle.com/en-us/iaas/mysql-database/)
- [PostgreSQL Database Service](https://docs.oracle.com/en-us/iaas/postgresql/)
