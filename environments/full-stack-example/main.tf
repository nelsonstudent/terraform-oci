# -----------------------------------------------------------------------------
# Provedor e Configurações Gerais
# -----------------------------------------------------------------------------
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# -----------------------------------------------------------------------------
# Módulo IAM: Criação de Compartments, Grupos e Políticas
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  tenancy_ocid          = var.tenancy_ocid
  parent_compartment_id = var.compartment_id

  groups = [
    { name = "${var.project_name}-admins", description = "Administradores do projeto ${var.project_name}" },
    { name = "${var.project_name}-developers", description = "Desenvolvedores do projeto ${var.project_name}" }
  ]

  policies = [
    {
      name        = "${var.project_name}-policy"
      description = "Política de acesso para o projeto ${var.project_name}"
      statements = [
        "Allow group ${var.project_name}-admins to manage all-resources in compartment id ${var.compartment_id}",
        "Allow group ${var.project_name}-developers to read all-resources in compartment id ${var.compartment_id}",
        "Allow group ${var.project_name}-developers to manage instance-family in compartment id ${var.compartment_id}",
        "Allow group ${var.project_name}-developers to manage cluster-family in compartment id ${var.compartment_id}",
        "Allow group ${var.project_name}-developers to manage repos in compartment id ${var.compartment_id}"
      ]
    }
  ]

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Módulo de Rede: VCN, Subnets, Gateways e Regras de Segurança
# -----------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  compartment_id  = var.compartment_id
  vcn_name        = "${var.project_name}-vcn"
  vcn_cidr_blocks = var.vcn_cidr_blocks
  vcn_dns_label   = var.project_name

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  allow_public_ssh   = true # Apenas para desenvolvimento, recomendado desabilitar em produção
  allow_public_http  = true
  allow_public_https = true

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Módulo de Load Balancer: Balanceamento de carga para a camada web
# -----------------------------------------------------------------------------
module "load_balancer" {
  source = "../../modules/load-balancer"

  compartment_id = var.compartment_id
  lb_name        = "${var.project_name}-lb"
  lb_shape       = "flexible"
  subnet_ids     = module.network.public_subnet_ids

  lb_min_bandwidth_mbps = var.lb_min_bandwidth
  lb_max_bandwidth_mbps = var.lb_max_bandwidth

  backend_sets = [
    {
      name   = "web-backend-set"
      policy = "ROUND_ROBIN"
      health_checker = {
        protocol    = "HTTP"
        port        = 80
        url_path    = "/"
        return_code = 200
        interval_ms = 10000
        timeout_in_millis = 3000
        retries     = 3
        response_body_regex = ""
      }
      backends = [
        for ip in module.web_servers.instance_private_ips : {
          ip_address = ip
          port       = 80
          weight     = 1
          backup     = false
          drain      = false
          offline    = false
        }
      ]
    }
  ]

  listeners = [
    {
      name                     = "http-listener"
      default_backend_set_name = "web-backend-set"
      port                     = 80
      protocol                 = "HTTP"
    }
  ]

  tags       = var.common_tags
  depends_on = [module.web_servers]
}

# -----------------------------------------------------------------------------
# Módulo Compute: Servidores Web (Frontend ) e de Aplicação (Backend)
# -----------------------------------------------------------------------------
module "web_servers" {
  source = "../../modules/compute"

  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  instance_name       = "${var.project_name}-web"
  instance_count      = var.web_instance_count
  instance_shape      = var.web_instance_shape
  subnet_id           = module.network.public_subnet_ids[0]
  assign_public_ip    = true
  ssh_public_key      = var.ssh_public_key

  instance_shape_config_ocpus         = var.web_instance_ocpus
  instance_shape_config_memory_in_gbs = var.web_instance_memory

  tags = merge(var.common_tags, { Role = "WebServer" })
}

module "app_servers" {
  source = "../../modules/compute"

  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  instance_name       = "${var.project_name}-app"
  instance_count      = var.app_instance_count
  instance_shape      = var.app_instance_shape
  subnet_id           = module.network.private_subnet_ids[0]
  assign_public_ip    = false
  ssh_public_key      = var.ssh_public_key

  instance_shape_config_ocpus         = var.app_instance_ocpus
  instance_shape_config_memory_in_gbs = var.app_instance_memory

  tags = merge(var.common_tags, { Role = "AppServer" })
}

# -----------------------------------------------------------------------------
# Módulo de Banco de Dados: Autonomous Database para a aplicação
# -----------------------------------------------------------------------------
module "database" {
  source = "../../modules/database"

  compartment_id = var.compartment_id
  subnet_id      = module.network.private_subnet_ids[0]
  display_name   = "${var.project_name}-db"
  admin_password = var.db_admin_password

  create_autonomous_database = true
  db_name                    = "${var.project_name}db"
  db_workload                = "OLTP"
  cpu_core_count             = 1
  data_storage_size_in_tbs   = 1
  is_auto_scaling_enabled    = true
  use_private_endpoint       = true

  tags = merge(var.common_tags, { Tier = "Database" })
}

# -----------------------------------------------------------------------------
# Módulo Container Registry: Repositórios para imagens Docker
# -----------------------------------------------------------------------------
module "container_registry" {
  source = "../../modules/container-registry"

  compartment_id = var.compartment_id
  repositories = [
    {
      name         = "${var.project_name}/frontend"
      is_public    = false
      is_immutable = false
    },
    {
      name         = "${var.project_name}/backend-api"
      is_public    = false
      is_immutable = true # Imagens de backend são imutáveis para consistência
    }
  ]

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Módulo Kubernetes: Cluster OKE para orquestração de contêineres
# -----------------------------------------------------------------------------
module "kubernetes" {
  source = "../../modules/kubernetes"

  compartment_id     = var.compartment_id
  cluster_name       = "${var.project_name}-oke-cluster"
  vcn_id             = module.network.vcn_id
  kubernetes_version = "v1.28.2"

  kubernetes_api_endpoint_subnet_id = module.network.public_subnet_ids[0]
  service_lb_subnet_ids             = [module.network.public_subnet_ids[0]]
  ssh_public_key                    = var.ssh_public_key

  node_pools = [
    {
      name              = "default-pool"
      node_shape        = "VM.Standard.E4.Flex"
      node_count        = 3
      node_shape_config = {
        ocpus         = 2
        memory_in_gbs = 16
      }
      placement_configs = [{
        availability_domain = var.availability_domain
        subnet_id           = module.network.private_subnet_ids[0]
      }]
    }
  ]

  tags = merge(var.common_tags, { Service = "OKE" })
}
