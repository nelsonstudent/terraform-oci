# Módulo Container Registry - OCI Terraform

Este módulo cria e configura repositórios no Oracle Cloud Infrastructure Registry (OCIR) para armazenar e gerenciar imagens de containers Docker.

## 📋 Recursos Criados

- **Container Repositories** - Repositórios para imagens Docker
- **Image Signatures** - Assinaturas criptográficas para verificação de imagens
- **Generic Repositories** - Repositórios para outros tipos de artefatos

## Uso Básico

```hcl
module "container_registry" {
  source = "../../modules/container-registry"
  
  compartment_id = var.compartment_id
  
  repositories = [
    {
      name           = "myapp/backend"
      is_public      = false
      is_immutable   = false
      readme_content = "Backend API container images"
      readme_format  = "text/plain"
    },
    {
      name           = "myapp/frontend"
      is_public      = false
      is_immutable   = false
      readme_content = "Frontend web application images"
      readme_format  = "text/plain"
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Variáveis

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|-------------|
| `compartment_id` | ID do compartment | `string` | - | Sim |
| `repositories` | Lista de repositórios a criar | `list(object)` | `[]` | Não |
| `generic_repositories` | Repositórios genéricos | `list(object)` | `[]` | Não |
| `image_signatures` | Assinaturas de imagens | `list(object)` | `[]` | Não |
| `tags` | Tags freeform | `map(string)` | `{}` | Não |

### Estrutura de Repositório

```hcl
{
  name           = string  # Nome do repositório (pode incluir namespaces)
  is_public      = bool    # Repositório público (sem autenticação)
  is_immutable   = bool    # Imagens não podem ser sobrescritas
  readme_content = string  # Conteúdo do README
  readme_format  = string  # "text/plain" ou "text/markdown"
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| `repository_ids` | Map de nomes e IDs dos repositórios |
| `repository_urls` | URLs dos repositórios |
| `image_signatures` | IDs das assinaturas de imagem |

## Exemplos de Uso

###/ Exemplo 1: Microservices Application

```hcl
module "microservices_registry" {
  source = "../../modules/container-registry"
  
  compartment_id = var.compartment_id
  
  repositories = [
    {
      name           = "${var.project_name}/api-gateway"
      is_public      = false
      is_immutable   = false
      readme_content = "API Gateway service"
      readme_format  = "text/plain"
    },
    {
      name           = "${var.project_name}/auth-service"
      is_public      = false
      is_immutable   = false
      readme_content = "Authentication service"
      readme_format  = "text/plain"
    },
    {
      name           = "${var.project_name}/user-service"
      is_public      = false
      is_immutable   = false
      readme_content = "User management service"
      readme_format  = "text/plain"
    },
    {
      name           = "${var.project_name}/payment-service"
      is_public      = false
      is_immutable   = true  # Imutável para auditoria
      readme_content = "Payment processing service"
      readme_format  = "text/plain"
    }
  ]
  
  tags = {
    Project     = var.project_name
    Environment = "Production"
    Team        = "Platform"
  }
}
```

### Exemplo 2: Repositórios com Namespaces Organizados

```hcl
module "organized_registry" {
  source = "../../modules/container-registry"
  
  compartment_id = var.compartment_id
  
  repositories = [
    # Backend services
    {
      name           = "company/backend/api"
      is_public      = false
      is_immutable   = false
      readme_content = "Main API backend"
      readme_format  = "text/plain"
    },
    {
      name           = "company/backend/worker"
      is_public      = false
      is_immutable   = false
      readme_content = "Background worker"
      readme_format  = "text/plain"
    },
    
    # Frontend applications
    {
      name           = "company/frontend/web"
      is_public      = false
      is_immutable   = false
      readme_content = "Web application"
      readme_format  = "text/plain"
    },
    {
      name           = "company/frontend/mobile-api"
      is_public      = false
      is_immutable   = false
      readme_content = "Mobile app backend"
      readme_format  = "text/plain"
    },
    
    # Shared/Common
    {
      name           = "company/common/nginx"
      is_public      = false
      is_immutable   = false
      readme_content = "Custom NGINX image"
      readme_format  = "text/plain"
    }
  ]
  
  tags = {
    Organization = "Company"
    ManagedBy    = "DevOps"
  }
}
```

### Exemplo 3: Repositório Público (Open Source)

```hcl
module "public_registry" {
  source = "../../modules/container-registry"
  
  compartment_id = var.compartment_id
  
  repositories = [
    {
      name           = "opensource/my-tool"
      is_public      = true  # Público - sem autenticação necessária
      is_immutable   = true  # Imutável - releases não podem ser alteradas
      readme_content = <<-EOF
        # My Open Source Tool
        
        Docker image for my-tool.
        
        ## Usage
        ```
        docker pull <region>.ocir.io/<tenancy>/opensource/my-tool:latest
        docker run opensource/my-tool
        ```
      EOF
      readme_format  = "text/markdown"
    }
  ]
  
  tags = {
    License = "MIT"
    Public  = "true"
  }
}
```

### Exemplo 4: Repositórios Imutáveis (Compliance)

```hcl
module "immutable_registry" {
  source = "../../modules/container-registry"
  
  compartment_id = var.compartment_id
  
  repositories = [
    {
      name           = "fintech/payment-processor"
      is_public      = false
      is_immutable   = true  # Imagens não podem ser alteradas/deletadas
      readme_content = "Payment processor - PCI-DSS compliant"
      readme_format  = "text/plain"
    },
    {
      name           = "fintech/fraud-detection"
      is_public      = false
      is_immutable   = true
      readme_content = "Fraud detection service"
      readme_format  = "text/plain"
    }
  ]
  
  tags = {
    Compliance = "PCI-DSS"
    Immutable  = "true"
    Audit      = "required"
  }
}
```

## Autenticação e Push/Pull de Imagens

### 1. Gerar Auth Token

```bash
# Via OCI Console
# Profile → User Settings → Auth Tokens → Generate Token

# Ou via CLI
oci iam auth-token create \
  --description "Docker Registry Token" \
  --user-id <user-ocid>
```

### 2. Docker Login

```bash
# Formato do registry: <region-key>.ocir.io
# Username: <tenancy-namespace>/<username>
# Password: <auth-token>

docker login sa-saopaulo-1.ocir.io
Username: mytenancy/john.wick@email.com
Password: <auth-token>
```

### 3. Tag e Push de Imagem

```bash
# Tag da imagem
docker tag myapp:latest sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest
docker tag myapp:latest sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0

# Push para OCIR
docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest
docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0

# Pull de imagem
docker pull sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0
```

### 4. Integração com CI/CD

#### GitHub Actions

```yaml
name: Build and Push to OCIR

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Login to OCIR
        uses: docker/login-action@v2
        with:
          registry: sa-saopaulo-1.ocir.io
          username: ${{ secrets.OCIR_USERNAME }}
          password: ${{ secrets.OCIR_TOKEN }}
      
      - name: Build and Push
        run: |
          docker build -t sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:${{ github.sha }} .
          docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:${{ github.sha }}
```

#### GitLab CI

```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $OCIR_USERNAME -p $OCIR_TOKEN sa-saopaulo-1.ocir.io
    - docker build -t sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:$CI_COMMIT_SHA .
    - docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:$CI_COMMIT_SHA
```

## Integração com OKE (Kubernetes)

### 1. Criar Secret para Pull de Imagens

```bash
kubectl create secret docker-registry ocir-secret \
  --docker-server=sa-saopaulo-1.ocir.io \
  --docker-username='mytenancy/john.wick@email.com' \
  --docker-password='<auth-token>' \
  --docker-email='john.wick@email.com'
```

### 2. Usar no Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: ocir-secret
```

### 3. Terraform para criar Secret

```hcl
resource "kubernetes_secret" "ocir" {
  metadata {
    name = "ocir-secret"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.region}.ocir.io" = {
          username = "${var.tenancy_namespace}/${var.username}"
          password = var.auth_token
          email    = var.email
          auth     = base64encode("${var.tenancy_namespace}/${var.username}:${var.auth_token}")
        }
      }
    })
  }
}
```

## Estrutura de Nomenclatura

### Recomendações

```
<region>.ocir.io/<tenancy-namespace>/<repo-name>:<tag>

Exemplos:
sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest
sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0
sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:dev-abc123

Estrutura recomendada:
<project>/<component>/<service>
```

### Estratégias de Tagging

```bash
# 1. Semantic Versioning
:v1.0.0
:v1.0.1
:v2.0.0

# 2. Git SHA
:abc1234
:${GIT_COMMIT_SHA}

# 3. Environment + Version
:prod-v1.0.0
:staging-v1.0.0
:dev-latest

# 4. Date-based
:2024-01-15
:20240115-1430

# 5. Latest + Versão
:latest
:v1.0.0
```

## Segurança

### Melhores Práticas

1. **Repositórios Privados por Padrão**
   ```hcl
   is_public = false  # Sempre privado a menos que necessário
   ```

2. **Imutabilidade para Produção**
   ```hcl
   is_immutable = true  # Produção - não permite sobrescrever tags
   ```

3. **Scan de Vulnerabilidades**
   ```bash
   # Integre com ferramentas como:
   # - Trivy
   # - Clair
   # - Snyk
   
   trivy image sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0
   ```

4. **Assinatura de Imagens**
   ```bash
   # Use Docker Content Trust ou Cosign
   export DOCKER_CONTENT_TRUST=1
   docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:v1.0.0
   ```

5. **Políticas de Retenção**
   - Defina quantas imagens manter
   - Delete imagens antigas automaticamente
   - Mantenha apenas tags importantes

6. **Acesso Baseado em IAM**
   ```hcl
   # Policy para permitir push/pull
   "Allow group Developers to manage repos in compartment MyCompartment"
   "Allow group Developers to read repos in compartment MyCompartment"
   ```

## Gerenciamento de Imagens

### Listar Imagens

```bash
# Via OCI CLI
oci artifacts container image list \
  --compartment-id <compartment-id> \
  --repository-name myapp/backend

# Ver tags de uma imagem
oci artifacts container image list \
  --compartment-id <compartment-id> \
  --repository-name myapp/backend \
  --display-name myapp/backend:v1.0.0
```

### Deletar Imagens

```bash
# Deletar imagem específica
oci artifacts container image delete \
  --image-id <image-ocid>

# Deletar por tag
oci artifacts container image delete \
  --repository-name myapp/backend \
  --image-version v1.0.0
```

### Políticas de Limpeza

```bash
# Script para deletar imagens antigas (exemplo)
#!/bin/bash

REPO_NAME="myapp/backend"
KEEP_LAST=10

# Obter lista de imagens ordenadas por data
IMAGES=$(oci artifacts container image list \
  --compartment-id $COMPARTMENT_ID \
  --repository-name $REPO_NAME \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --all)

# Deletar imagens além das N mais recentes
# Implementar lógica de cleanup
```

## Regiões do OCIR

| Região | Registry URL |
|--------|--------------|
| São Paulo | `sa-saopaulo-1.ocir.io` |
| Ashburn | `us-ashburn-1.ocir.io` |
| Phoenix | `us-phoenix-1.ocir.io` |
| Frankfurt | `eu-frankfurt-1.ocir.io` |
| London | `uk-london-1.ocir.io` |
| Mumbai | `ap-mumbai-1.ocir.io` |
| Seoul | `ap-seoul-1.ocir.io` |
| Sydney | `ap-sydney-1.ocir.io` |
| Tokyo | `ap-tokyo-1.ocir.io` |
| Toronto | `ca-toronto-1.ocir.io` |

## Custos

### Modelo de Preços

- **Armazenamento**: ~$0.025 por GB/mês
- **Tráfego de Saída**: Varia por região
- **Tráfego Interno**: Grátis (mesma região)

### Otimização

1. **Multi-stage Builds**
   ```dockerfile
   # Build stage
   FROM node:16 AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm install
   COPY . .
   RUN npm run build
   
   # Production stage
   FROM node:16-alpine
   WORKDIR /app
   COPY --from=builder /app/dist ./dist
   CMD ["node", "dist/main.js"]
   ```

2. **Cache de Layers**
   ```dockerfile
   # Copiar package.json primeiro para cache
   COPY package*.json ./
   RUN npm install
   # Depois copiar código
   COPY . .
   ```

3. **Limpeza de Imagens Antigas**
   - Mantenha apenas versões necessárias
   - Delete imagens de desenvolvimento

4. **Compressão**
   - Use imagens base Alpine quando possível
   - Remova arquivos desnecessários

## Monitoramento

### Métricas Disponíveis

- Número de imagens por repositório
- Tamanho total do armazenamento
- Número de pulls/pushes
- Imagens vulneráveis

### Alertas

```hcl
resource "oci_monitoring_alarm" "registry_storage" {
  display_name = "OCIR Storage Alert"
  compartment_id = var.compartment_id
  
  metric_compartment_id = var.compartment_id
  namespace = "oci_artifacts"
  query = "StorageSize[1m].mean() > 100000000000"  # 100GB
  
  severity = "WARNING"
  # ...
}
```

## Migração de Outros Registries

### Do Docker Hub

```bash
# Pull da imagem do Docker Hub
docker pull nginx:latest

# Tag para OCIR
docker tag nginx:latest sa-saopaulo-1.ocir.io/mytenancy/common/nginx:latest

# Push para OCIR
docker push sa-saopaulo-1.ocir.io/mytenancy/common/nginx:latest
```

### Do AWS ECR

```bash
# Login no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

# Pull
docker pull <account>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Tag para OCIR
docker tag <account>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest \
  sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest

# Push para OCIR
docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest
```

### Do Google GCR

```bash
# Login no GCR
gcloud auth configure-docker

# Pull
docker pull gcr.io/project-id/myapp:latest

# Tag para OCIR
docker tag gcr.io/project-id/myapp:latest \
  sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest

# Push para OCIR
docker push sa-saopaulo-1.ocir.io/mytenancy/myapp/backend:latest
```

## Troubleshooting

### Erro: "unauthorized: authentication required"

**Solução:**
```bash
# Verifique o auth token
# Formato correto do username: <tenancy-namespace>/<username>
docker login sa-saopaulo-1.ocir.io
```

### Erro: "denied: requested access to the resource is denied"

**Solução:**
- Verifique IAM policies
- Usuário precisa de permissão `manage repos` ou `read repos`

### Erro: "name unknown: repository not found"

**Solução:**
- Verifique se o repositório foi criado via Terraform
- Confirme o nome está correto (case-sensitive)

### Push muito lento

**Solução:**
- Use registry na mesma região
- Otimize Dockerfile (multi-stage builds)
- Verifique conectividade de rede

### Kubernetes não consegue pull

**Solução:**
```bash
# Verifique o secret
kubectl get secret ocir-secret -o yaml

# Recrie o secret se necessário
kubectl delete secret ocir-secret
kubectl create secret docker-registry ocir-secret \
  --docker-server=<region>.ocir.io \
  --docker-username='<tenancy>/<user>' \
  --docker-password='<token>'
```

## Recursos Adicionais

- [OCIR Documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/home.htm)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Image Pull Secrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
