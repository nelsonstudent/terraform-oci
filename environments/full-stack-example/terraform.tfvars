# -----------------------------------------------------------------------------
# Preencha com suas credenciais e informações da OCI
# -----------------------------------------------------------------------------
region              = "sa-saopaulo-1"
tenancy_ocid        = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid           = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint         = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path    = "~/.oci/oci_api_key.pem"
compartment_id      = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
availability_domain = "Uocm:SA-SAOPAULO-1-AD-1"

# -----------------------------------------------------------------------------
# Chave SSH - Substitua pelo conteúdo da sua chave pública
# -----------------------------------------------------------------------------
ssh_public_key = "ssh-rsa AAAA..."

# -----------------------------------------------------------------------------
# Senha do Banco de Dados - Use uma senha forte e considere usar um Vault
# -----------------------------------------------------------------------------
db_admin_password = "SuaSenhaForteParaOBanco#2025"

# -----------------------------------------------------------------------------
# Configurações do Projeto
# -----------------------------------------------------------------------------
project_name = "fstack-prod"

common_tags = {
  Environment = "Production"
  Project     = "FullStackApp"
  ManagedBy   = "Terraform"
  Owner       = "Equipe-Alpha"
}

# -----------------------------------------------------------------------------
# Configuração de Rede
# -----------------------------------------------------------------------------
public_subnets = [
  {
    name      = "public-subnet"
    cidr      = "10.0.1.0/24"
    dns_label = "public"
  }
]

private_subnets = [
  {
    name      = "private-app-subnet"
    cidr      = "10.0.10.0/24"
    dns_label = "privateapp"
  },
  {
    name      = "private-db-subnet"
    cidr      = "10.0.11.0/24"
    dns_label = "privatedb"
  }
]
