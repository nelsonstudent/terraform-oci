output "repository_ids" {
  description = "Map de nomes e IDs dos repositórios"
  value       = { for k, v in oci_artifacts_container_repository.this : k => v.id }
}

output "repository_urls" {
  description = "URLs dos repositórios"
  value = {
    for k, v in oci_artifacts_container_repository.this : k => {
      name = v.display_name
      url  = "${var.compartment_id}/${v.display_name}"
    }
  }
}

output "image_signatures" {
  description = "IDs das assinaturas de imagem"
  value       = { for k, v in oci_artifacts_container_image_signature.this : k => v.id }
}
