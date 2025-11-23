### Módulo Terraform para OCI Web Application Firewall (WAF)

Este módulo Terraform provisiona uma política de Web Application Firewall (WAF) e a associa a um Load Balancer na Oracle Cloud Infrastructure (OCI). Ele é projetado para configurar a proteção de segurança da sua aplicação de forma automatizada, incluindo regras de acesso, proteção de requisições e controle de taxa.

## Funcionalidades:

- Cria uma Política WAF: Define uma política WAF com ações e regras personalizadas para proteger sua aplicação.
- Associa a um Load Balancer: Anexa a política WAF a um Load Balancer da OCI, integrando-a ao fluxo de tráfego.
- Configuração Flexível: Suporta a criação de regras de controle de acesso, proteção contra ameaças e limitação de taxa de requisições.
- Integração de Segurança: Permite a definição de ações de segurança personalizadas, como retornar respostas HTTP específicas para requisições bloqueadas.
- Suporte a Tags: Aplica tags freeform e defined para metadados e rastreamento de custos.

## Pré-requisitos:

- Terraform: Certifique-se de que o Terraform esteja instalado e configurado para acessar sua conta OCI.
- Permissões: Sua conta OCI precisa ter as permissões necessárias para criar e gerenciar políticas WAF, além de ter um Load Balancer já provisionado.
- Load Balancer: Este módulo requer um Load Balancer existente, pois ele faz a associação da política WAF a ele.

## Como Usar: 

Para usar este módulo, inclua-o em seu arquivo main.tf e defina a variável waf no seu arquivo terraform.tfvars.
Exemplo de terraform.tfvars

```hcl
waf = {
  name               = "waf-policy-producao"
  load_balancer_name = "LB-PRINCIPAL"
  actions = [
    {
      type = "ALLOW"
      name = "defaultAction"
    },
    {
      type = "RETURN_HTTP_RESPONSE"
      name = "return401Response"
      code = 401
      body = {
        type = "STATIC_TEXT"
        text = "{\n\"code\": 401,\n\"message\":\"Unauthorized\"\n}"
      }
      headers = [
        {
          name  = "X-Security-Header"
          value = "Blocked"
        }
      ]
    }
  ]
  request_accesss_control = {
    default_action_name = "defaultAction"
    rules = [
      {
        type               = "ACCESS_CONTROL"
        name               = "block-ip-rule"
        action_name        = "return401Response"
        condition          = "ip.address in ('10.0.0.1')"
        condition_language = "CEL"
      }
    ]
  }
  request_protection = {
    body_inspection_size_limit_exceeded_action_name = "return401Response"
    body_inspection_size_limit_in_bytes             = 8192
    rules = [
      {
        type                       = "PROTECTION"
        name                       = "requestProtectionRule"
        action_name                = "return401Response"
        is_body_inspection_enabled = true
        condition                  = ""
        condition_language         = ""
        protection_capabilities = [
          {
            key     = "9300000"
            version = 1
          }
        ]
      }
    ]
  }
}
```

## Variáveis:

As variáveis deste módulo são gerenciadas principalmente através do mapa waf.

| Nome	| Descrição	| Tipo	| Padrão |
|-------|-----------|-------|--------|
| waf	| Um mapa que contém a configuração completa da política WAF e suas regras.	| any	| null |
| compartment_id	| O OCID do compartimento onde a política WAF será criada.	| string	| n/a |
| compartment_name	| O nome do compartimento para fins de tags.	| string	| n/a |
| tag_cost_tracker	| O namespace da tag para rastreamento de custos.	| string	| n/a |
| common_tags	| Tags freeform que serão aplicadas a todos os recursos criados pelo módulo.	| map(string)	| n/a |

## Outputs:

| Nome	| Descrição |
|-------|-----------|
| waf_policy_id	| O OCID da política WAF criada. |
| waf_policy_name	| O nome da política WAF criada. |
| web_app_firewall_id	| O OCID do Web Application Firewall associado ao Load Balancer. |
| web_app_firewall_name	| O nome do Web Application Firewall associado ao Load Balancer. |
