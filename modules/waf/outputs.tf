output "waf_policy_id" {
  value = oci_waf_web_app_firewall_policy.waf_policy.id
  description = "OCID da política WAF criada"
}

output "waf_policy_name" {
  value = oci_waf_web_app_firewall_policy.waf_policy.display_name
  description = "Nome da política WAF criada"
}

output "web_app_firewall_id" {
  value = oci_waf_web_app_firewall.waf.id
  description = "OCID do Web Application Firewall associado ao Load Balancer"
}

output "web_app_firewall_name" {
  value = oci_waf_web_app_firewall.waf.display_name
  description = "Nome do Web Application Firewall associado ao Load Balancer"
}
