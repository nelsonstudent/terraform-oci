# environments/cliente-exemplo/outputs.tf

# Network Outputs
output "vcn_id" {
  description = "ID da VCN criada"
  value       = module.network.vcn_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.network.private_subnet_ids
}

# Web Servers Outputs
output "web_server_ids" {
  description = "IDs dos web servers"
  value       = module.web_servers.instance_ids
}

output "web_server_public_ips" {
  description = "IPs públicos dos web servers"
  value       = module.web_servers.instance_public_ips
}

output "web_server_private_ips" {
  description = "IPs privados dos web servers"
  value       = module.web_servers.instance_private_ips
}

# App Servers Outputs
output "app_server_ids" {
  description = "IDs dos app servers"
  value       = module.app_servers.instance_ids
}

output "app_server_private_ips" {
  description = "IPs privados dos app servers"
  value       = module.app_servers.instance_private_ips
}

output "app_server_block_volume_ids" {
  description = "IDs dos block volumes dos app servers"
  value       = module.app_servers.block_volume_ids
}

# Load Balancer Outputs
output "load_balancer_id" {
  description = "ID do Load Balancer"
  value       = module.load_balancer.load_balancer_id
}

output "load_balancer_ip_addresses" {
  description = "Endereços IP do Load Balancer"
  value       = module.load_balancer.load_balancer_ip_addresses
}

output "load_balancer_public_ip" {
  description = "IP público do Load Balancer (para acesso)"
  value       = try(module.load_balancer.load_balancer_ip_addresses[0].ip_address, null)
}

# Summary Output
output "infrastructure_summary" {
  description = "Resumo da infraestrutura criada"
  value = {
    cliente = var.cliente_name
    region  = var.region
    
    network = {
      vcn_id             = module.network.vcn_id
      vcn_cidr           = module.network.vcn_cidr_blocks
      public_subnets     = length(module.network.public_subnet_ids)
      private_subnets    = length(module.network.private_subnet_ids)
    }
    
    compute = {
      web_servers = {
        count       = var.web_instance_count
        shape       = var.web_instance_shape
        ocpus       = var.web_instance_ocpus
        memory_gb   = var.web_instance_memory
        public_ips  = module.web_servers.instance_public_ips
      }
      app_servers = {
        count       = var.app_instance_count
        shape       = var.app_instance_shape
        ocpus       = var.app_instance_ocpus
        memory_gb   = var.app_instance_memory
        private_ips = module.app_servers.instance_private_ips
      }
    }
    
    load_balancer = {
      name      = "${var.cliente_name}-lb"
      shape     = "flexible"
      bandwidth = "${var.lb_min_bandwidth}-${var.lb_max_bandwidth} Mbps"
      public_ip = try(module.load_balancer.load_balancer_ip_addresses[0].ip_address, "pending")
    }
  }
}

# Connection Info
output "connection_info" {
  description = "Informações de conexão"
  value = {
    load_balancer_url = "http://${try(module.load_balancer.load_balancer_ip_addresses[0].ip_address, "pending")}"
    web_servers_ssh   = [
      for i, ip in module.web_servers.instance_public_ips : 
      "ssh opc@${ip}  # ${module.web_servers.instance_names[i]}"
    ]
    note = "Para acessar app servers, use bastion/jump host através dos web servers"
  }
  sensitive = false
}
