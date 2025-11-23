### Módulo Terraform para Gerenciamento de Compartimentos da OCI

Este módulo Terraform é projetado para criar e gerenciar compartimentos na sua conta Oracle Cloud Infrastructure (OCI). Ele configura uma estrutura de compartimentos principal e, opcionalmente, sub-compartimentos, garantindo uma organização lógica e consistência nas suas implantações na nuvem.

## Funcionalidades

- Cria um compartimento principal na sua tenancy raiz.
- Cria múltiplos sub-compartimentos dentro do compartimento principal.
- Aplica tags freeform e defined para rastreamento de custos e metadados.
- Garante que os recursos sejam criados na região principal da sua conta.
- Ignora tags geradas automaticamente pela OCI (Oracle-Tags.CreatedBy, - - Oracle-Tags.CreatedOn, etc.) para evitar alterações indesejadas.

## Pré-requisitos:

- Terraform: Certifique-se de que o Terraform esteja instalado e configurado para acessar sua conta OCI.
- Permissões: Sua conta OCI precisa ter as permissões necessárias para criar e gerenciar compartimentos e tags na tenancy raiz.

## Como Usar:

```hcl
Para usar este módulo, inclua-o no seu arquivo main.tf e forneça os valores para as variáveis necessárias.

module "compartments" {
  source = "./caminho/para/o/seu/modulo" # Altere o caminho conforme a sua estrutura

  # Variáveis obrigatórias
  default_region_account = "sa-saopaulo-1"
  tenancy_ocid           = "ocid1.tenancy.oc1..xxxxx"

  # Configuração do compartimento principal
  client_compartment = {
    name = "meu-compartimento-principal"
  }

  # Configuração dos sub-compartimentos
  sub_compartments = [
    "sub-compartimento-dev",
    "sub-compartimento-prod"
  ]
  
  # Tags para rastreamento de custo e comuns
  tag_cost_tracker = "tag-custo-rastreador"
  common_tags = {
    Owner     = "equipe-infra"
    Project   = "projeto-xyz"
  }
}

# Saídas do módulo
output "compartment_principal" {
  value = module.compartments.client_compartment_id
}

output "nome_compartimento" {
  value = module.compartments.client_compartment_name
}
```

## Variáveis:


| Nome	| Descrição	| Tipo	| Obrigatório |
|-------|-----------|-------|-------------|
| `default_region_account`	| Define a região padrão da sua conta para a criação de compartimentos.	| string	| Sim |
| `tenancy_ocid`	| O OCID da sua tenancy (entidade raiz).	| string	| Sim |
| `client_compartment`	| Um mapa contendo o nome do compartimento principal.	| map(string)	| Sim |
| `sub_compartments`	| Uma lista de nomes para os sub-compartimentos.	| list(string)	| Não |
| `tag_cost_tracker`	| O namespace das tags para rastrear custos.	| string	| Sim |
| `common_tags`	| Tags comuns (freeform) a serem aplicadas a todos os recursos.	| map(string)	| Sim |


## Outputs:

| Nome	| Descrição |
|-------|-----------|
| client_compartment_id	| O ID do compartimento principal do ambiente. |
| client_compartment_name	| O nome do compartimento principal do ambiente. |
