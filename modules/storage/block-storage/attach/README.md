### Módulo Terraform para OCI Block Volume

Este módulo Terraform é projetado para criar e anexar volumes de armazenamento (Block Volumes) a instâncias de computação na Oracle Cloud Infrastructure (OCI). A estrutura do módulo é dividida em dois sub-módulos: um para a criação do volume e outro para a anexação, permitindo flexibilidade e reutilização.


## Funcionalidades

- Cria volumes de armazenamento (Block Volumes) configuráveis.
- Anexa volumes existentes a instâncias de computação.
- Suporte para políticas de backup de volume (bronze, silver, gold).
- Configuração de tipo de anexo (paravirtualized).
- Configuração de tags freeform e defined para os volumes.
- Utiliza data sources para buscar dinamicamente os IDs de compartimentos, instâncias e volumes.

## Pré-requisitos:

- Terraform: Certifique-se de que o Terraform esteja instalado e configurado para acessar sua conta OCI.
- Permissões: Sua conta OCI precisa ter as permissões necessárias para criar e gerenciar volumes, anexos de volume e políticas de backup.
- Instâncias e Compartimentos: Este módulo assume que as instâncias e volumes já existem ou que você irá referenciá-los por seus nomes.

## Como Usar

Este módulo é composto por dois sub-módulos. Você pode chamá-los separadamente, dependendo da sua necessidade.

1. Criando um Block Volume
Para criar um Block Volume, use o sub-módulo block-storage:

```hcl
module "my_block_volume" {
  source = "./storage/block-storage" # Altere o caminho conforme sua estrutura

  # Variáveis do Block Volume
  client_compartment_id   = "ocid1.compartment.oc1..xxxxxx"
  client_compartment_name = "compartimento-raiz"
  compartment_name        = "meu-compartimento"
  display_name            = "volume-para-webserver"
  size_in_gbs             = 100
  backup_policy_name      = "bronze" # Opcional: "bronze", "silver", ou "gold"
  common_tags = {
    "Owner" = "equipe-infra"
  }
  tag_cost_tracker = "tag-custo-rastreador"
}
```

2. Anexando um Block Volume
Para anexar um Block Volume a uma instância, use o sub-módulo attach:

```hcl
module "attach_my_volume" {
  source = "./storage/block-storage/attach" # Altere o caminho conforme sua estrutura

  # Variáveis de anexação
  client_compartment_id     = "ocid1.compartment.oc1..xxxxxx"
  instance_compartment_name = "meu-compartimento"
  instance_name             = "web-server-01"
  block_volumes             = ["volume-para-webserver"] # Lista de nomes de volumes a serem anexados
}
```


### Variáveis

| Nome	| Sub-módulo	| Descrição	| Tipo	| Obrigatório |
|-------|---------------|-----------|-------|-------------|
| client_compartment_id	| Ambos	O OCID do compartimento raiz.	| string	| Sim |
| client_compartment_name	| block-storage	Nome do compartimento raiz.	| string	| Sim |
| instance_compartment_name	| attach	| O nome do compartimento da instância onde o volume será anexado.	| string	| Sim |
| instance_name	| attach	| Nome da instância à qual o volume será anexado.	| string	| Sim |
| block_volumes	| attach	| Lista de nomes dos volumes a serem anexados.	| list(string)	| Sim |
| display_name	| block-storage	| Nome de exibição do volume.	| string	| Sim |
| size_in_gbs	| block-storage	| Tamanho do volume em GB.	| number	| Sim |
| backup_policy_name	| block-storage	| Nome da política de backup do volume (bronze, silver, gold).	| string	| Não |
| compartment_name	| block-storage	| O nome do compartimento onde o volume será criado.	| string	| Sim |
| common_tags	| block-storage	| Tags freeform a serem aplicadas ao volume.	| map(string)	| Sim |
| tag_cost_tracker	| block-storage	| Namespace da tag de custo definida.	| string	| Sim |


### Tipos de Políticas de Backup

## Bronze

A política bronze inclui backups incrementais mensais, executados no primeiro dia do mês. Esses backups são mantidos por doze meses. Esta política também inclui um backup incremental, executado anualmente durante a primeira metade do mês de janeiro. Esse backup é mantido por cinco anos.

## Silver

A política prata inclui backups incrementais semanais que são executados aos domingos. Esses backups são mantidos por quatro semanas. Essa política também inclui backups incrementais mensais, executados no primeiro dia do mês e são mantidos por doze meses. Também inclui um backup incremental, executado anualmente durante a primeira metade do mês de janeiro. Esse backup é mantido por cinco anos.

## Gold

A política de ouro inclui backups incrementais diários, retidos por sete dias, juntamente com backups incrementais semanais, executados no domingo e retidos por quatro semanas. Inclui backups incrementais mensais, executados no primeiro dia do mês, que são mantidos por doze meses. Também inclui um backup incremental, executado anualmente durante a primeira metade do mês de janeiro. Esse backup é mantido por cinco anos.
