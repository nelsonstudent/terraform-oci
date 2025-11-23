# modules/compute/variables.tf

variable "compartment_id" {
  description = "ID do compartment"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain para criar a instância"
  type        = string
}

variable "instance_name" {
  description = "Nome da instância"
  type        = string
}

variable "instance_count" {
  description = "Número de instâncias a criar"
  type        = number
  default     = 1
}

variable "instance_shape" {
  description = "Shape da instância (ex: VM.Standard.E4.Flex, VM.Standard3.Flex, BM.Standard.E4.128)"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_shape_config_ocpus" {
  description = "Número de OCPUs para shapes Flex"
  type        = number
  default     = 1
}

variable "instance_shape_config_memory_in_gbs" {
  description = "Quantidade de memória em GB para shapes Flex"
  type        = number
  default     = 16
}

variable "instance_os" {
  description = "Sistema operacional"
  type        = string
  default     = "Oracle Linux"
}

variable "instance_os_version" {
  description = "Versão do sistema operacional"
  type        = string
  default     = "8"
}

variable "image_name_filter" {
  description = "Filtro regex para nome da imagem"
  type        = string
  default     = ".*"
}

variable "source_image_id" {
  description = "ID da imagem customizada (opcional, se não fornecido usa a imagem do data source)"
  type        = string
  default     = null
}

variable "boot_volume_size_in_gbs" {
  description = "Tamanho do boot volume em GB"
  type        = number
  default     = 50
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "assign_public_ip" {
  description = "Atribuir IP público à instância"
  type        = bool
  default     = false
}

variable "hostname_label" {
  description = "Label do hostname"
  type        = string
  default     = null
}

variable "private_ips" {
  description = "Lista de IPs privados para as instâncias"
  type        = list(string)
  default     = null
}

variable "nsg_ids" {
  description = "Lista de IDs de Network Security Groups"
  type        = list(string)
  default     = []
}

variable "skip_source_dest_check" {
  description = "Desabilitar verificação source/destination (útil para NAT instances)"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso à instância"
  type        = string
}

variable "user_data" {
  description = "Script cloud-init para executar na inicialização"
  type        = string
  default     = null
}

variable "custom_metadata" {
  description = "Metadata customizado adicional"
  type        = map(string)
  default     = {}
}

variable "disable_all_plugins" {
  description = "Desabilitar todos os plugins do agente"
  type        = bool
  default     = false
}

variable "disable_management" {
  description = "Desabilitar gerenciamento via agente"
  type        = bool
  default     = false
}

variable "disable_monitoring" {
  description = "Desabilitar monitoramento via agente"
  type        = bool
  default     = false
}

variable "enabled_plugins" {
  description = "Lista de plugins habilitados"
  type = list(object({
    name          = string
    desired_state = string
  }))
  default = []
}

variable "is_live_migration_preferred" {
  description = "Preferir live migration durante manutenção"
  type        = bool
  default     = true
}

variable "recovery_action" {
  description = "Ação de recuperação (RESTORE_INSTANCE ou STOP_INSTANCE)"
  type        = string
  default     = "RESTORE_INSTANCE"
}

variable "enable_pv_encryption_in_transit" {
  description = "Habilitar criptografia em trânsito para volumes paravirtualizados"
  type        = bool
  default     = false
}

variable "preserve_boot_volume" {
  description = "Preservar boot volume após destruir a instância"
  type        = bool
  default     = false
}

# Block Volume variables
variable "create_block_volume" {
  description = "Criar e anexar block volume adicional"
  type        = bool
  default     = false
}

variable "block_volume_size_in_gbs" {
  description = "Tamanho do block volume em GB"
  type        = number
  default     = 50
}

variable "block_volume_vpus_per_gb" {
  description = "VPUs por GB do block volume (performance)"
  type        = number
  default     = 10
}

variable "block_volume_attachment_type" {
  description = "Tipo de attachment (iscsi, paravirtualized)"
  type        = string
  default     = "paravirtualized"
}

variable "block_volume_device" {
  description = "Device path para o block volume"
  type        = string
  default     = null
}

variable "block_volume_read_only" {
  description = "Anexar block volume como read-only"
  type        = bool
  default     = false
}

variable "block_volume_shareable" {
  description = "Permitir que block volume seja compartilhável"
  type        = bool
  default     = false
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
