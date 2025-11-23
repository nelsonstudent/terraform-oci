# Tags comuns
locals {
  module_common_tags = {
    module = "waf"
  }
}

resource "oci_waf_web_app_firewall_policy" "waf_policy" {
  compartment_id = var.compartment_id
  display_name   = var.waf.name
  freeform_tags  = merge(var.common_tags, local.module_common_tags)
  defined_tags   = { "${var.tag_cost_tracker}" = var.compartment_name }

  request_access_control {
    default_action_name = var.waf.request_accesss_control.default_action_name
    dynamic "rules" {
      iterator = each_rule_req
      for_each = {
        for rule in var.waf.request_accesss_control.rules : rule.name => rule
      }
      content {
        type               = each_rule_req.value.type
        name               = each_rule_req.value.name
        action_name        = each_rule_req.value.action_name
        condition          = each_rule_req.value.condition
        condition_language = each_rule_req.value.condition_language
      }
    }
  }
  response_access_control {
    dynamic "rules" {
      iterator = each_rule_res
      for_each = {
        for rule in var.waf.response_access_control.rules : rule.name => rule
      }
      content {
        type               = each_rule_res.value.type
        name               = each_rule_res.value.name
        action_name        = each_rule_res.value.action_name
        condition          = each_rule_res.value.condition
        condition_language = each_rule_res.value.condition_language
      }
    }
  }
  request_rate_limiting {
    dynamic "rules" {
      iterator = each_rule_reqrl
      for_each = {
        for rule in var.waf.request_rate_limiting.rules : rule.name => rule
      }
      content {
        type               = each_rule_reqrl.value.type
        name               = each_rule_reqrl.value.name
        action_name        = each_rule_reqrl.value.action_name
        condition          = each_rule_reqrl.value.condition
        condition_language = each_rule_reqrl.value.condition_language
        configurations {
          period_in_seconds          = each_rule_reqrl.value.configurations.period_in_seconds
          requests_limit             = each_rule_reqrl.value.configurations.requests_limit
          action_duration_in_seconds = each_rule_reqrl.value.configurations.action_duration_in_seconds
        }
      }
    }
  }

  request_protection {
    body_inspection_size_limit_exceeded_action_name = var.waf.request_protection.body_inspection_size_limit_exceeded_action_name
    body_inspection_size_limit_in_bytes             = var.waf.request_protection.body_inspection_size_limit_in_bytes

    dynamic "rules" {
      iterator = each_rule_reqp
      for_each = {
        for rule in var.waf.request_protection.rules : rule.name => rule
      }
      content {
        type               = each_rule_reqp.value.type
        name               = each_rule_reqp.value.name
        action_name        = each_rule_reqp.value.action_name
        condition          = each_rule_reqp.value.condition
        condition_language = each_rule_reqp.value.condition_language
        dynamic "protection_capabilities" {
          iterator = each_rule_pc
          for_each = {
            for pc in each_rule_reqp.value.protection_capabilities : pc.key => pc
          }
          content {
            key     = each_rule_pc.value.key
            version = each_rule_pc.value.version
          }
        }
      }
    }
  }
  dynamic "actions" {
    iterator = each_action
    for_each = {
      for action in var.waf.actions : action.name => action if action.type == "RETURN_HTTP_RESPONSE"
    }

    content {
      name = each_action.value.name
      type = each_action.value.type
      code = each_action.value.code
      body {
        type = each_action.value.body.type
        text = each_action.value.body.text
      }
      dynamic "headers" {
        iterator = each_header
        for_each = {
          for header in each_action.value.headers : header.name => header
        }

        content {
          name  = each_header.value.name
          value = each_header.value.value
        }
      }
    }
  }
  dynamic "actions" {
    iterator = each_action
    for_each = {
      for action in var.waf.actions : action.name => action if action.type == "CHECK" || action.type == "ALLOW"
    }
    content {
      name = each_action.value.name
      type = each_action.value.type
    }
  }

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedDate"],
      defined_tags["Oracle-Tags.CreatedOn"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"]
    ]
  }
}

resource "oci_waf_web_app_firewall" "waf" {
  load_balancer_id = element(data.oci_load_balancer_load_balancers.list_load_balancers.load_balancers, index(
    data.oci_load_balancer_load_balancers.list_load_balancers.load_balancers[*].display_name, var.waf.load_balancer_name
  )).id
  compartment_id             = var.compartment_id
  backend_type               = "LOAD_BALANCER"
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.waf_policy.id
  display_name               = var.waf.name
  freeform_tags              = merge(var.common_tags, local.module_common_tags)
  defined_tags               = { "${var.tag_cost_tracker}" = var.compartment_name }

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedDate"],
      defined_tags["Oracle-Tags.CreatedOn"],
      defined_tags["ResouceInfo.Date"],
      defined_tags["ResouceInfo.Principal"]
    ]
  }
}

data "oci_load_balancer_load_balancers" "list_load_balancers" {
  compartment_id = var.compartment_id
}
