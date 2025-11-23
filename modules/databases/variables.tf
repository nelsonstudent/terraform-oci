variable "compartment_id" {
  description = "ID do compartment"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID da subnet"
  type        = string
}

variable "nsg_ids" {
  description = "IDs dos Network Security Groups"
  type        = list(string)
  default     = []
}

# Common variables
variable "display_name" {
  description = "Nome de exibição do database"
  type        = string
}

variable "description" {
  description = "Descrição do database"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
}

# Autonomous Database variables
variable "create_autonomous_database" {
  description = "Criar Autonomous Database"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Nome do database (apenas letras e números)"
  type        = string
  default     = ""
}

variable "db_workload" {
  description = "Tipo de workload (OLTP, DW, AJD, APEX)"
  type        = string
  default     = "OLTP"
}

variable "cpu_core_count" {
  description = "Número de CPUs (OCPU)"
  type        = number
  default     = 1
}

variable "data_storage_size_in_tbs" {
  description = "Tamanho do storage em TB"
  type        = number
  default     = 1
}

variable "is_auto_scaling_enabled" {
  description = "Habilitar auto scaling de CPU"
  type        = bool
  default     = false
}

variable "is_auto_scaling_for_storage_enabled" {
  description = "Habilitar auto scaling de storage"
  type        = bool
  default     = false
}

variable "is_free_tier" {
  description = "Usar free tier (Always Free)"
  type        = bool
  default     = false
}

variable "is_preview" {
  description = "Usar versão preview"
  type        = bool
  default     = false
}

variable "license_model" {
  description = "Modelo de licença (LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE)"
  type        = string
  default     = "LICENSE_INCLUDED"
}

variable "db_version" {
  description = "Versão do database"
  type        = string
  default     = "19c"
}

variable "is_data_guard_enabled" {
  description = "Habilitar Data Guard (standby)"
  type        = bool
  default     = false
}

variable "maintenance_schedule_type" {
  description = "Tipo de schedule de manutenção (EARLY, REGULAR)"
  type        = string
  default     = "REGULAR"
}

variable "whitelisted_ips" {
  description = "Lista de IPs permitidos"
  type        = list(string)
  default     = null
}

variable "use_private_endpoint" {
  description = "Usar endpoint privado"
  type        = bool
  default     = true
}

variable "private_endpoint_label" {
  description = "Label do endpoint privado"
  type        = string
  default     = null
}

variable "create_manual_backup" {
  description = "Criar backup manual"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Dias de retenção do backup"
  type        = number
  default     = 60
}

# MySQL variables
variable "create_mysql" {
  description = "Criar MySQL Database"
  type        = bool
  default     = false
}

variable "mysql_shape" {
  description = "Shape do MySQL (MySQL.VM.Standard.E3.1.8GB, etc)"
  type        = string
  default     = "MySQL.VM.Standard.E3.1.8GB"
}

variable "mysql_admin_username" {
  description = "Username do admin MySQL"
  type        = string
  default     = "admin"
}

variable "mysql_configuration_id" {
  description = "ID da configuração MySQL"
  type        = string
  default     = null
}

variable "mysql_data_storage_gb" {
  description = "Tamanho do storage em GB"
  type        = number
  default     = 50
}

variable "hostname_label" {
  description = "Label do hostname"
  type        = string
  default     = null
}

variable "mysql_ip_address" {
  description = "IP address do MySQL"
  type        = string
  default     = null
}

variable "mysql_port" {
  description = "Porta do MySQL"
  type        = number
  default     = 3306
}

variable "mysql_port_x" {
  description = "Porta X Protocol do MySQL"
  type        = number
  default     = 33060
}

variable "mysql_backup_enabled" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "mysql_backup_retention_days" {
  description = "Dias de retenção de backup"
  type        = number
  default     = 7
}

variable "mysql_backup_window_start" {
  description = "Horário de início do backup (HH:MM)"
  type        = string
  default     = "02:00"
}

variable "mysql_pitr_enabled" {
  description = "Habilitar Point-in-Time Recovery"
  type        = bool
  default     = false
}

variable "mysql_maintenance_window_start" {
  description = "Horário de início da manutenção"
  type        = string
  default     = "SUNDAY 02:00"
}

variable "mysql_is_highly_available" {
  description = "Configurar para alta disponibilidade"
  type        = bool
  default     = false
}

# PostgreSQL variables
variable "create_postgresql" {
  description = "Criar PostgreSQL Database"
  type        = bool
  default     = false
}

variable "postgresql_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "14"
}

variable "postgresql_shape" {
  description = "Shape do PostgreSQL"
  type        = string
  default     = "PostgreSQL.VM.Standard.E4.Flex.2.32GB"
}

variable "postgresql_regional_storage" {
  description = "Usar storage regional"
  type        = bool
  default     = true
}

variable "postgresql_storage_type" {
  description = "Tipo de storage"
  type        = string
  default     = "OCI_OPTIMIZED_STORAGE"
}

variable "postgresql_admin_username" {
  description = "Username do admin PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "postgresql_instance_count" {
  description = "Número de instâncias PostgreSQL"
  type        = number
  default     = 1
}

variable "postgresql_instance_ocpus" {
  description = "OCPUs por instância"
  type        = number
  default     = 2
}

variable "postgresql_instance_memory_gb" {
  description = "Memória em GB por instância"
  type        = number
  default     = 32
}

variable "tags" {
  description = "Tags freeform"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Tags definidas"
  type        = map(string)
  default     = {}
}
