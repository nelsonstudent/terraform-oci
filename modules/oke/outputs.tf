output "cluster_id" {
  description = "ID do cluster OKE"
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "Nome do cluster"
  value       = oci_containerengine_cluster.this.name
}

output "cluster_kubernetes_version" {
  description = "Versão do Kubernetes"
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "cluster_endpoints" {
  description = "Endpoints do cluster"
  value       = oci_containerengine_cluster.this.endpoints
}

output "cluster_api_endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = try(oci_containerengine_cluster.this.endpoints[0].kubernetes, null)
}

output "kubeconfig" {
  description = "Conteúdo do kubeconfig"
  value       = data.oci_containerengine_cluster_kube_config.this.content
  sensitive   = true
}

output "node_pool_ids" {
  description = "Map de nomes e IDs dos node pools"
  value       = { for k, v in oci_containerengine_node_pool.this : k => v.id }
}

output "node_pool_details" {
  description = "Detalhes dos node pools"
  value = {
    for k, v in oci_containerengine_node_pool.this : k => {
      id                 = v.id
      name               = v.name
      kubernetes_version = v.kubernetes_version
      node_shape         = v.node_shape
      node_count         = v.node_config_details[0].size
    }
  }
}

output "virtual_node_pool_ids" {
  description = "Map de nomes e IDs dos virtual node pools"
  value       = { for k, v in oci_containerengine_virtual_node_pool.this : k => v.id }
}

output "available_kubernetes_versions" {
  description = "Versões disponíveis do Kubernetes"
  value       = data.oci_containerengine_cluster_option.this.kubernetes_versions
}

output "connection_instructions" {
  description = "Instruções para conectar ao cluster"
  value = <<-EOT
  Para configurar o kubectl, execute:
  
  oci ce cluster create-kubeconfig \
    --cluster-id ${oci_containerengine_cluster.this.id} \
    --file $HOME/.kube/config \
    --region ${var.compartment_id} \
    --token-version 2.0.0
  
  Ou use:
  terraform output -raw kubeconfig > ~/.kube/config
  
  Depois teste:
  kubectl get nodes
  kubectl get pods -A
  EOT
}
