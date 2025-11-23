# Exemplo de uso dos módulos para um novo cliente

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Módulo de Network
module "network" {
  source = "../../modules/network"
  
  compartment_id = var.compartment_id
  vcn_name       = "${var.cliente_name}-vcn"
  vcn_cidr_blocks = var.vcn_cidr_blocks
  vcn_dns_label  = var.vcn_dns_label
  
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
  
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  
  allow_public_ssh   = var.allow_public_ssh
  allow_public_http  = true
  allow_public_https = true
  
  tags = var.common_tags
}

# Módulo de Compute - Web Servers
module "web_servers" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "${var.cliente_name}-web"
  instance_count = var.web_instance_count
  instance_shape = var.web_instance_shape
  
  instance_shape_config_ocpus         = var.web_instance_ocpus
  instance_shape_config_memory_in_gbs = var.web_instance_memory
  
  subnet_id        = module.network.public_subnet_ids[0]
  assign_public_ip = true
  ssh_public_key   = var.ssh_public_key
  
  boot_volume_size_in_gbs = var.web_boot_volume_size
  
  user_data = var.web_user_data
  
  tags = merge(
    var.common_tags,
    {
      Tier = "Web"
      Role = "WebServer"
    }
  )
  
  depends_on = [module.network]
}

# Módulo de Compute - App Servers (Private)
module "app_servers" {
  source = "../../modules/compute"
  
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  instance_name  = "${var.cliente_name}-app"
  instance_count = var.app_instance_count
  instance_shape = var.app_instance_shape
  
  instance_shape_config_ocpus         = var.app_instance_ocpus
  instance_shape_config_memory_in_gbs = var.app_instance_memory
  
  subnet_id        = module.network.private_subnet_ids[0]
  assign_public_ip = false
  ssh_public_key   = var.ssh_public_key
  
  boot_volume_size_in_gbs = var.app_boot_volume_size
  
  create_block_volume         = true
  block_volume_size_in_gbs    = var.app_data_volume_size
  block_volume_attachment_type = "paravirtualized"
  
  user_data = var.app_user_data
  
  tags = merge(
    var.common_tags,
    {
      Tier = "Application"
      Role = "AppServer"
    }
  )
  
  depends_on = [module.network]
}

# Módulo de Load Balancer
module "load_balancer" {
  source = "../../modules/load-balancer"
  
  compartment_id = var.compartment_id
  lb_name        = "${var.cliente_name}-lb"
  lb_shape       = "flexible"
  
  lb_min_bandwidth_mbps = var.lb_min_bandwidth
  lb_max_bandwidth_mbps = var.lb_max_bandwidth
  
  subnet_ids = module.network.public_subnet_ids
  is_private = false
  
  backend_sets = [
    {
      name   = "web-backend"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol            = "HTTP"
        port                = 80
        url_path            = "/health"
        return_code         = 200
        interval_ms         = 10000
        timeout_in_millis   = 3000
        retries             = 3
        response_body_regex = ""
      }
      session_persistence_cookie_name      = null
      session_persistence_disable_fallback = false
      ssl_configuration                    = null
      backends = [
        for i, ip in module.web_servers.instance_private_ips : {
          ip_address = ip
          port       = 80
          backup     = false
          drain      = false
          offline    = false
          weight     = 1
        }
      ]
    }
  ]
  
  listeners = [
    {
      name                     = "http-listener"
      default_backend_set_name = "web-backend"
      port                     = 80
      protocol                 = "HTTP"
      connection_configuration = {
        idle_timeout_in_seconds = 300
      }
      ssl_configuration = null
    }
  ]
  
  tags = var.common_tags
  
  depends_on = [module.web_servers]
}
