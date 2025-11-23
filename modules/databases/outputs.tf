# Autonomous Database outputs
output "autonomous_database_id" {
  description = "ID do Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].id : null
}

output "autonomous_database_connection_strings" {
  description = "Connection strings do Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].connection_strings : null
}

output "autonomous_database_connection_urls" {
  description = "URLs de conexão do Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].connection_urls : null
}

output "autonomous_database_private_endpoint" {
  description = "Private endpoint do Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].private_endpoint : null
}

# MySQL outputs
output "mysql_id" {
  description = "ID do MySQL Database System"
  value       = var.create_mysql ? oci_mysql_mysql_db_system.this[0].id : null
}

output "mysql_endpoints" {
  description = "Endpoints do MySQL"
  value       = var.create_mysql ? oci_mysql_mysql_db_system.this[0].endpoints : null
}

output "mysql_ip_address" {
  description = "IP address do MySQL"
  value       = var.create_mysql ? oci_mysql_mysql_db_system.this[0].ip_address : null
}

output "mysql_port" {
  description = "Porta do MySQL"
  value       = var.create_mysql ? oci_mysql_mysql_db_system.this[0].port : null
}

# PostgreSQL outputs
output "postgresql_id" {
  description = "ID do PostgreSQL Database System"
  value       = var.create_postgresql ? oci_psql_db_system.this[0].id : null
}

output "postgresql_instances" {
  description = "Instâncias do PostgreSQL"
  value       = var.create_postgresql ? oci_psql_db_system.this[0].instances : null
}

# Connection info
output "connection_info" {
  description = "Informações de conexão consolidadas"
  value = {
    autonomous_db = var.create_autonomous_database ? {
      type               = "Autonomous Database"
      workload          = var.db_workload
      connection_strings = oci_database_autonomous_database.this[0].connection_strings
      admin_user        = "ADMIN"
    } : null
    
    mysql = var.create_mysql ? {
      type      = "MySQL"
      host      = oci_mysql_mysql_db_system.this[0].ip_address
      port      = oci_mysql_mysql_db_system.this[0].port
      admin_user = var.mysql_admin_username
    } : null
    
    postgresql = var.create_postgresql ? {
      type       = "PostgreSQL"
      instances  = oci_psql_db_system.this[0].instances
      admin_user = var.postgresql_admin_username
    } : null
  }
  sensitive = false
}
