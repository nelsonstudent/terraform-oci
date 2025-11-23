# Módulo para Autonomous Database, MySQL e PostgreSQL

# Autonomous Database
resource "oci_database_autonomous_database" "this" {
  count              = var.create_autonomous_database ? 1 : 0
  compartment_id     = var.compartment_id
  db_name            = var.db_name
  display_name       = var.display_name
  admin_password     = var.admin_password
  
  # Workload type
  db_workload = var.db_workload  # OLTP, DW, AJD, APEX
  
  # Compute and Storage
  cpu_core_count           = var.cpu_core_count
  data_storage_size_in_tbs = var.data_storage_size_in_tbs
  
  # Networking
  subnet_id                = var.subnet_id
  nsg_ids                  = var.nsg_ids
  private_endpoint_label   = var.private_endpoint_label
  
  # Features
  is_auto_scaling_enabled               = var.is_auto_scaling_enabled
  is_auto_scaling_for_storage_enabled   = var.is_auto_scaling_for_storage_enabled
  is_free_tier                          = var.is_free_tier
  is_preview_version_with_service_terms_accepted = var.is_preview
  
  # License
  license_model = var.license_model  # LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE
  
  # Backup
  db_version                           = var.db_version
  is_data_guard_enabled                = var.is_data_guard_enabled
  autonomous_maintenance_schedule_type = var.maintenance_schedule_type
  
  # Access Control
  whitelisted_ips = var.whitelisted_ips
  are_primary_whitelisted_ips_used = var.use_private_endpoint ? false : true
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# MySQL Database System
resource "oci_mysql_mysql_db_system" "this" {
  count               = var.create_mysql ? 1 : 0
  compartment_id      = var.compartment_id
  shape_name          = var.mysql_shape
  subnet_id           = var.subnet_id
  admin_username      = var.mysql_admin_username
  admin_password      = var.admin_password
  availability_domain = var.availability_domain
  
  display_name = var.display_name
  description  = var.description
  
  # Configuration
  configuration_id = var.mysql_configuration_id
  
  # Storage
  data_storage_size_in_gb = var.mysql_data_storage_gb
  
  # Networking
  hostname_label = var.hostname_label
  ip_address     = var.mysql_ip_address
  port           = var.mysql_port
  port_x         = var.mysql_port_x
  
  # Backup
  backup_policy {
    is_enabled        = var.mysql_backup_enabled
    retention_in_days = var.mysql_backup_retention_days
    window_start_time = var.mysql_backup_window_start
    
    dynamic "pitr_policy" {
      for_each = var.mysql_pitr_enabled ? [1] : []
      content {
        is_enabled = true
      }
    }
  }
  
  # Maintenance
  maintenance {
    window_start_time = var.mysql_maintenance_window_start
  }
  
  # High Availability
  is_highly_available = var.mysql_is_highly_available
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# PostgreSQL Database System  
resource "oci_psql_db_system" "this" {
  count               = var.create_postgresql ? 1 : 0
  compartment_id      = var.compartment_id
  db_version          = var.postgresql_version
  display_name        = var.display_name
  shape               = var.postgresql_shape
  network_details {
    subnet_id = var.subnet_id
    nsg_ids   = var.nsg_ids
  }
  
  # Storage
  storage_details {
    is_regionally_durable = var.postgresql_regional_storage
    system_type          = var.postgresql_storage_type  # OCI_OPTIMIZED_STORAGE
    availability_domain  = var.postgresql_regional_storage ? null : var.availability_domain
  }
  
  # Credentials
  credentials {
    username         = var.postgresql_admin_username
    password_details {
      password_type = "PLAIN_TEXT"
      password      = var.admin_password
    }
  }
  
  # Instance configuration
  instance_count       = var.postgresql_instance_count
  instance_ocpu_count  = var.postgresql_instance_ocpus
  instance_memory_size_in_gbs = var.postgresql_instance_memory_gb
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Autonomous Database Backup
resource "oci_database_autonomous_database_backup" "this" {
  count                      = var.create_autonomous_database && var.create_manual_backup ? 1 : 0
  autonomous_database_id     = oci_database_autonomous_database.this[0].id
  display_name               = "${var.db_name}-manual-backup"
  retention_period_in_days   = var.backup_retention_days
}

# Data source for available DB versions
data "oci_database_autonomous_db_versions" "adb_versions" {
  count          = var.create_autonomous_database ? 1 : 0
  compartment_id = var.compartment_id
  db_workload    = var.db_workload
}

data "oci_mysql_shapes" "mysql_shapes" {
  count          = var.create_mysql ? 1 : 0
  compartment_id = var.compartment_id
}
