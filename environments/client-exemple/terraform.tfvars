# environments/cliente-exemplo/terraform.tfvars
# Arquivo de variáveis para configuração do cliente
# COPIE ESTE ARQUIVO E AJUSTE OS VALORES PARA CADA NOVO CLIENTE

# Configurações OCI
region              = "sa-saopaulo-1"
tenancy_ocid        = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
user_ocid           = "ocid1.user.oc1..aaaaaaaaxxxxxx"
fingerprint         = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path    = "~/.oci/oci_api_key.pem"
compartment_id      = "ocid1.compartment.oc1..aaaaaaaaxxxxxx"

# Nome do Cliente (usado como prefixo em todos os recursos)
cliente_name = "exemplo-corp"

# Configurações de Rede
vcn_cidr_blocks = ["10.0.0.0/16"]
vcn_dns_label   = "exemplovcn"

public_subnets = [
  {
    name      = "public-subnet-ad1"
    cidr      = "10.0.1.0/24"
    dns_label = "publicsub1"
  },
  {
    name      = "public-subnet-ad2"
    cidr      = "10.0.2.0/24"
    dns_label = "publicsub2"
  }
]

private_subnets = [
  {
    name      = "private-subnet-ad1"
    cidr      = "10.0.10.0/24"
    dns_label = "privatesub1"
  },
  {
    name      = "private-subnet-ad2"
    cidr      = "10.0.11.0/24"
    dns_label = "privatesub2"
  }
]

allow_public_ssh = false

# Web Servers (Públicos)
web_instance_count  = 2
web_instance_shape  = "VM.Standard.E4.Flex"
web_instance_ocpus  = 1
web_instance_memory = 16
web_boot_volume_size = 50

# Script de inicialização para web servers (opcional)
web_user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Web Server - $(hostname)</h1>" > /var/www/html/index.html
echo "OK" > /var/www/html/health
EOF

# App Servers (Privados)
app_instance_count   = 2
app_instance_shape   = "VM.Standard.E4.Flex"
app_instance_ocpus   = 2
app_instance_memory  = 32
app_boot_volume_size = 100
app_data_volume_size = 200

# Script de inicialização para app servers (opcional)
app_user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y java-11-openjdk
# Configurações adicionais da aplicação
EOF

# Load Balancer
lb_min_bandwidth = 10
lb_max_bandwidth = 100

# Chave SSH (cole sua chave pública aqui)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... seu_usuario@seu_computador"

# Tags Comuns
common_tags = {
  Environment = "Production"
  Cliente     = "Exemplo Corp"
  ManagedBy   = "Terraform"
  CostCenter  = "TI"
}
