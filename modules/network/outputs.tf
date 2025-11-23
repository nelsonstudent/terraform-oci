# modules/network/outputs.tf

output "vcn_id" {
  description = "ID da VCN criada"
  value       = oci_core_vcn.this.id
}

output "vcn_cidr_blocks" {
  description = "Blocos CIDR da VCN"
  value       = oci_core_vcn.this.cidr_blocks
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = var.create_internet_gateway ? oci_core_internet_gateway.this[0].id : null
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway"
  value       = var.create_nat_gateway ? oci_core_nat_gateway.this[0].id : null
}

output "service_gateway_id" {
  description = "ID do Service Gateway"
  value       = var.create_service_gateway ? oci_core_service_gateway.this[0].id : null
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = oci_core_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = oci_core_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID da route table pública"
  value       = var.create_internet_gateway ? oci_core_route_table.public[0].id : null
}

output "private_route_table_id" {
  description = "ID da route table privada"
  value       = var.create_nat_gateway ? oci_core_route_table.private[0].id : null
}

output "public_security_list_id" {
  description = "ID da security list pública"
  value       = oci_core_security_list.public.id
}

output "private_security_list_id" {
  description = "ID da security list privada"
  value       = oci_core_security_list.private.id
}
