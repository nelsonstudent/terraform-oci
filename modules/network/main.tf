# modules/network/main.tf
# Módulo para criar VCN completa com subnets públicas e privadas

# VCN
resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  display_name   = var.vcn_name
  cidr_blocks    = var.vcn_cidr_blocks
  dns_label      = var.vcn_dns_label
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Internet Gateway
resource "oci_core_internet_gateway" "this" {
  count          = var.create_internet_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-igw"
  enabled        = true
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# NAT Gateway
resource "oci_core_nat_gateway" "this" {
  count          = var.create_nat_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-nat"
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Service Gateway
resource "oci_core_service_gateway" "this" {
  count          = var.create_service_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-sgw"
  
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Data source para serviços OCI
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Route Table - Public
resource "oci_core_route_table" "public" {
  count          = var.create_internet_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-rt-public"
  
  route_rules {
    network_entity_id = oci_core_internet_gateway.this[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Route Table - Private
resource "oci_core_route_table" "private" {
  count          = var.create_nat_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-rt-private"
  
  dynamic "route_rules" {
    for_each = var.create_nat_gateway ? [1] : []
    content {
      network_entity_id = oci_core_nat_gateway.this[0].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  
  dynamic "route_rules" {
    for_each = var.create_service_gateway ? [1] : []
    content {
      network_entity_id = oci_core_service_gateway.this[0].id
      destination       = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Security List - Public
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-sl-public"
  
  # Egress - Allow all
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
  
  # Ingress - SSH
  dynamic "ingress_security_rules" {
    for_each = var.allow_public_ssh ? [1] : []
    content {
      protocol    = "6" # TCP
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options {
        min = 22
        max = 22
      }
    }
  }
  
  # Ingress - HTTP
  dynamic "ingress_security_rules" {
    for_each = var.allow_public_http ? [1] : []
    content {
      protocol    = "6" # TCP
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options {
        min = 80
        max = 80
      }
    }
  }
  
  # Ingress - HTTPS
  dynamic "ingress_security_rules" {
    for_each = var.allow_public_https ? [1] : []
    content {
      protocol    = "6" # TCP
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options {
        min = 443
        max = 443
      }
    }
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Security List - Private
resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.vcn_name}-sl-private"
  
  # Egress - Allow all
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
  
  # Ingress - Allow from VCN
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr_blocks[0]
    stateless   = false
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Public Subnets
resource "oci_core_subnet" "public" {
  count               = length(var.public_subnets)
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.this.id
  cidr_block          = var.public_subnets[count.index].cidr
  display_name        = var.public_subnets[count.index].name
  dns_label           = var.public_subnets[count.index].dns_label
  route_table_id      = var.create_internet_gateway ? oci_core_route_table.public[0].id : null
  security_list_ids   = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Private Subnets
resource "oci_core_subnet" "private" {
  count               = length(var.private_subnets)
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.this.id
  cidr_block          = var.private_subnets[count.index].cidr
  display_name        = var.private_subnets[count.index].name
  dns_label           = var.private_subnets[count.index].dns_label
  route_table_id      = var.create_nat_gateway ? oci_core_route_table.private[0].id : null
  security_list_ids   = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}
