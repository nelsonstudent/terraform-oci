# Container Repository
resource "oci_artifacts_container_repository" "this" {
  for_each       = { for repo in var.repositories : repo.name => repo }
  compartment_id = var.compartment_id
  display_name   = each.value.name
  is_public      = each.value.is_public
  is_immutable   = each.value.is_immutable
  
  readme {
    content = each.value.readme_content
    format  = each.value.readme_format
  }
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Container Image Signature
resource "oci_artifacts_container_image_signature" "this" {
  for_each = {
    for sig in var.image_signatures : "${sig.repository_name}-${sig.image_digest}" => sig
  }
  
  compartment_id        = var.compartment_id
  image_id              = each.value.image_id
  kms_key_id            = each.value.kms_key_id
  kms_key_version_id    = each.value.kms_key_version_id
  message               = each.value.message
  signature             = each.value.signature
  signing_algorithm     = each.value.signing_algorithm
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Repository Lifecycle Policy
resource "oci_artifacts_repository" "this" {
  for_each       = { for repo in var.generic_repositories : repo.name => repo }
  compartment_id = var.compartment_id
  display_name   = each.value.name
  is_immutable   = each.value.is_immutable
  repository_type = each.value.repository_type
  description    = each.value.description
  
  freeform_tags = var.tags
  defined_tags  = var.defined_tags
}

# Data sources
data "oci_artifacts_container_images" "this" {
  for_each       = { for repo in var.repositories : repo.name => repo }
  compartment_id = var.compartment_id
  repository_name = oci_artifacts_container_repository.this[each.key].display_name
  
  depends_on = [oci_artifacts_container_repository.this]
}
