# modules/load-balancer/outputs.tf

output "load_balancer_id" {
  description = "ID do Load Balancer"
  value       = oci_load_balancer_load_balancer.this.id
}

output "load_balancer_ip_addresses" {
  description = "Endereços IP do Load Balancer"
  value       = oci_load_balancer_load_balancer.this.ip_address_details
}

output "backend_set_names" {
  description = "Nomes dos backend sets criados"
  value       = [for bs in oci_load_balancer_backend_set.this : bs.name]
}

output "listener_names" {
  description = "Nomes dos listeners criados"
  value       = [for listener in oci_load_balancer_listener.this : listener.name]
}

output "certificate_names" {
  description = "Nomes dos certificados criados"
  value       = [for cert in oci_load_balancer_certificate.this : cert.certificate_name]
}
