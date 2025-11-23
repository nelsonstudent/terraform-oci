# Módulo Kubernetes (OKE) - OCI Terraform

Este módulo cria e configura clusters Oracle Kubernetes Engine (OKE) completos com node pools, virtual node pools e todas as configurações necessárias para produção.

## Recursos Criados

- **OKE Cluster** - Cluster Kubernetes gerenciado
- **Node Pools** - Pools de worker nodes (VMs)
- **Virtual Node Pools** - Pools serverless (opcional)
- **Network Configuration** - Endpoints e service load balancers
- **KubeConfig** - Arquivo de configuração para kubectl

## Uso Básico

```hcl
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  compartment_id     = var.compartment_id
  cluster_name       = "my-oke-cluster"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.28.2"
  
  # Cluster configuration
  cluster_type = "ENHANCED_CLUSTER"
  cni_type     = "FLANNEL_OVERLAY"
  
  # API Endpoint
  is_public_api_endpoint            = true
  kubernetes_api_endpoint_subnet_id = var.public_subnet_id
  
  # Service Load Balancers
  service_lb_subnet_ids = [var.public_subnet_id]
  
  # SSH Key
  ssh_public_key = var.ssh_public_key
  
  # Node Pool
  node_pools = [
    {
      name                                = "pool-1"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 3
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 50
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 2
        memory_in_gbs = 32
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.private_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels      = []
      tags             = {}
      defined_tags     = {}
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Variáveis Principais

### Cluster

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `compartment_id` | ID do compartment | `string` | - |
| `cluster_name` | Nome do cluster | `string` | - |
| `vcn_id` | ID da VCN | `string` | - |
| `kubernetes_version` | Versão do Kubernetes | `string` | `"v1.28.2"` |
| `cluster_type` | Tipo do cluster | `string` | `"ENHANCED_CLUSTER"` |
| `cni_type` | Tipo de CNI | `string` | `"FLANNEL_OVERLAY"` |

### API Endpoint

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `is_public_api_endpoint` | API endpoint público | `bool` | `true` |
| `kubernetes_api_endpoint_subnet_id` | Subnet para API | `string` | - |
| `kubernetes_api_endpoint_nsg_ids` | NSG IDs para API | `list(string)` | `[]` |

### Service Load Balancers

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `service_lb_subnet_ids` | Subnets para LBs | `list(string)` | - |

### Node Pool (objeto complexo)

Ver estrutura completa em `variables.tf`

## Outputs

| Nome | Descrição |
|------|-----------|
| `cluster_id` | ID do cluster OKE |
| `cluster_name` | Nome do cluster |
| `cluster_kubernetes_version` | Versão do Kubernetes |
| `cluster_endpoints` | Endpoints do cluster |
| `cluster_api_endpoint` | Endpoint da API Kubernetes |
| `kubeconfig` | Conteúdo do kubeconfig (sensível) |
| `node_pool_ids` | Map de node pools |
| `node_pool_details` | Detalhes dos node pools |
| `virtual_node_pool_ids` | Map de virtual node pools |
| `available_kubernetes_versions` | Versões disponíveis do Kubernetes |
| `connection_instructions` | Instruções para conectar ao cluster |

## Exemplos de Uso

### Exemplo 1: Cluster de Produção com HA

Stack com alta disponibilidade multi-AD para produção.

```hcl
module "production_k8s" {
  source = "../../modules/kubernetes"
  
  compartment_id     = var.compartment_id
  cluster_name       = "prod-k8s"
  vcn_id             = module.network.vcn_id
  kubernetes_version = "v1.28.2"
  
  cluster_type = "ENHANCED_CLUSTER"
  cni_type     = "FLANNEL_OVERLAY"
  
  is_public_api_endpoint            = false  # API privada
  kubernetes_api_endpoint_subnet_id = module.network.private_subnet_ids[0]
  service_lb_subnet_ids             = module.network.public_subnet_ids
  
  is_pod_security_policy_enabled = true
  ssh_public_key                 = var.ssh_public_key
  
  node_pools = [
    {
      name                                = "general-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 3
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 100
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = true
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 4
        memory_in_gbs = 64
      }
      placement_configs = [
        {
          availability_domain     = data.oci_identity_availability_domains.ads.availability_domains[0].name
          subnet_id               = module.network.private_subnet_ids[0]
          capacity_reservation_id = null
          fault_domains           = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2"]
        },
        {
          availability_domain     = data.oci_identity_availability_domains.ads.availability_domains[1].name
          subnet_id               = module.network.private_subnet_ids[1]
          capacity_reservation_id = null
          fault_domains           = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2"]
        }
      ]
      node_labels = [
        {
          key   = "workload"
          value = "general"
        }
      ]
      tags         = {}
      defined_tags = {}
    }
  ]
  
  tags = {
    Environment = "Production"
    Criticality = "High"
  }
}
```

### Exemplo 2: Cluster com Múltiplos Node Pools

Stack com 3 node pools separados para diferentes workloads.

```hcl
module "multi_pool_k8s" {
  source = "../../modules/kubernetes"
  
  compartment_id     = var.compartment_id
  cluster_name       = "multi-pool-k8s"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.28.2"
  
  cluster_type = "ENHANCED_CLUSTER"
  
  is_public_api_endpoint            = true
  kubernetes_api_endpoint_subnet_id = var.public_subnet_id
  service_lb_subnet_ids             = [var.public_subnet_id]
  ssh_public_key                    = var.ssh_public_key
  
  node_pools = [
    # Web Frontend Tier
    {
      name                                = "web-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 3
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 50
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 2
        memory_in_gbs = 16
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.worker_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels = [
        {
          key   = "workload"
          value = "web"
        },
        {
          key   = "tier"
          value = "frontend"
        }
      ]
      tags         = {}
      defined_tags = {}
    },
    
    # Application Backend Tier
    {
      name                                = "backend-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 5
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 100
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 4
        memory_in_gbs = 32
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.worker_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels = [
        {
          key   = "workload"
          value = "backend"
        },
        {
          key   = "tier"
          value = "application"
        }
      ]
      tags         = {}
      defined_tags = {}
    },
    
    # Batch Processing Tier
    {
      name                                = "batch-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 2
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 100
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 8
        memory_in_gbs = 64
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.worker_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels = [
        {
          key   = "workload"
          value = "batch"
        },
        {
          key   = "spot"
          value = "true"
        }
      ]
      tags         = {}
      defined_tags = {}
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

### Exemplo 3: Cluster com Virtual Nodes (Serverless)

Stack com virtual nodes para workloads serverless.

```hcl
module "serverless_k8s" {
  source = "../../modules/kubernetes"
  
  compartment_id     = var.compartment_id
  cluster_name       = "serverless-k8s"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.28.2"
  
  cluster_type = "ENHANCED_CLUSTER"
  cni_type     = "OCI_VCN_IP_NATIVE"  # Necessário para virtual nodes
  
  is_public_api_endpoint            = true
  kubernetes_api_endpoint_subnet_id = var.public_subnet_id
  service_lb_subnet_ids             = [var.public_subnet_id]
  
  node_pools = [
    {
      name                                = "system-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 2
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 50
      image_id                            = null
      ssh_public_key                      = var.ssh_public_key
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 1
        memory_in_gbs = 16
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.worker_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels = [
        {
          key   = "workload"
          value = "system"
        }
      ]
      tags         = {}
      defined_tags = {}
    }
  ]
  
  virtual_node_pools = [
    {
      name          = "serverless-pool"
      size          = 0  # Auto-scale
      pod_subnet_id = var.pod_subnet_id
      pod_shape     = "Pod.Standard.E4.Flex"
      nsg_ids       = []
      pod_shape_config = {
        ocpus         = 1
        memory_in_gbs = 16
      }
      placement_configs = [
        {
          availability_domain = var.availability_domain
          subnet_id           = var.worker_subnet_id
          fault_domains       = []
        }
      ]
      node_labels = [
        {
          key   = "type"
          value = "virtual"
        }
      ]
      taints = []
      tags         = {}
      defined_tags = {}
    }
  ]
  
  tags = {
    Environment = "Production"
    Type        = "Serverless"
  }
}
```

### Exemplo 4: Cluster de Desenvolvimento

Stack leve e econômico para desenvolvimento.

```hcl
module "dev_k8s" {
  source = "../../modules/kubernetes"
  
  compartment_id     = var.compartment_id
  cluster_name       = "dev-k8s"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.28.2"
  
  cluster_type = "BASIC_CLUSTER"  # Grátis
  cni_type     = "FLANNEL_OVERLAY"
  
  is_public_api_endpoint            = true
  kubernetes_api_endpoint_subnet_id = var.public_subnet_id
  service_lb_subnet_ids             = [var.public_subnet_id]
  ssh_public_key                    = var.ssh_public_key
  
  node_pools = [
    {
      name                                = "dev-pool"
      node_shape                          = "VM.Standard.E4.Flex"
      node_count                          = 2
      kubernetes_version                  = null
      boot_volume_size_in_gbs            = 50
      image_id                            = null
      ssh_public_key                      = null
      is_pv_encryption_in_transit_enabled = false
      kms_key_id                          = null
      nsg_ids                             = []
      pod_subnet_ids                      = null
      node_shape_config = {
        ocpus         = 1
        memory_in_gbs = 8
      }
      placement_configs = [
        {
          availability_domain     = var.availability_domain
          subnet_id               = var.worker_subnet_id
          capacity_reservation_id = null
          fault_domains           = []
        }
      ]
      node_labels      = []
      tags             = {}
      defined_tags     = {}
    }
  ]
  
  tags = {
    Environment = "Development"
    CostCenter  = "Dev"
  }
}
```

## Tipos de Cluster

### BASIC_CLUSTER
- **Custo**: Grátis (controle do plano de controle)
- **Funcionalidades**: Básicas
- **SLA**: 99.5%
- **Ideal para**: Desenvolvimento, teste, aprendizado

### ENHANCED_CLUSTER
- **Custo**: ~$0.10/hora por cluster
- **Funcionalidades**: Avançadas (observabilidade, policy, etc)
- **SLA**: 99.95%
- **Ideal para**: Produção, crítico

## CNI Types

### FLANNEL_OVERLAY
- **Padrão**: Sim
- **Complexidade**: Simples
- **Performance**: Boa
- **IPs de Pod**: Gerenciados pelo Flannel
- **Ideal para**: Maioria dos casos

### OCI_VCN_IP_NATIVE
- **Padrão**: Não
- **Complexidade**: Maior
- **Performance**: Excelente
- **IPs de Pod**: Vêm da VCN
- **Ideal para**: Virtual nodes, networking avançado

## Node Pool Shapes

| Shape | OCPUs | RAM (GB) | Rede | Uso |
|-------|-------|----------|------|-----|
| `VM.Standard.E4.Flex` | 1-64 | 1-1024 | Até 40 Gbps | Uso geral |
| `VM.Standard.E5.Flex` | 1-94 | 1-1504 | Até 100 Gbps | Performance |
| `VM.Standard3.Flex` | 1-32 | 1-512 | Até 32 Gbps | Intel |
| `VM.Standard.A1.Flex` | 1-80 | 1-512 | Até 40 Gbps | ARM (econômico) |
| `BM.Standard.E4.128` | 128 | 2048 | 2x 50 Gbps | Bare Metal |

## Acesso ao Cluster

### 1. Obter Kubeconfig

```bash
# Via Terraform Output
terraform output -raw kubeconfig > ~/.kube/config

# Ou via OCI CLI
oci ce cluster create-kubeconfig \
  --cluster-id <cluster-ocid> \
  --file $HOME/.kube/config \
  --region sa-saopaulo-1 \
  --token-version 2.0.0
```

### 2. Verificar Conectividade

```bash
# Testar conexão
kubectl cluster-info

# Ver nodes
kubectl get nodes

# Ver todos os pods
kubectl get pods -A

# Ver eventos
kubectl get events -A --sort-by='.lastTimestamp'
```

### 3. Deploy de Aplicação

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      nodeSelector:
        workload: web
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f deployment.yaml
kubectl get svc nginx  # Obter IP externo
```

## Autenticação e RBAC

### 1. Criar ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-binding
subjects:
- kind: ServiceAccount
  name: my-app-sa
roleRef:
  kind: Role
  name: my-app-role
  apiGroup: rbac.authorization.k8s.io
```

### 2. Integração com OCI IAM

```hcl
# Dynamic group para OKE nodes
resource "oci_identity_dynamic_group" "oke_nodes" {
  name          = "oke-nodes-dg"
  description   = "Dynamic group for OKE nodes"
  compartment_id = var.tenancy_ocid
  matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"
}

# Policy para nodes acessarem OCIR
resource "oci_identity_policy" "oke_policy" {
  name           = "oke-policy"
  description    = "Policy for OKE nodes"
  compartment_id = var.compartment_id
  
  statements = [
    "Allow dynamic-group oke-nodes-dg to read repos in compartment id ${var.compartment_id}",
    "Allow dynamic-group oke-nodes-dg to use keys in compartment id ${var.compartment_id}"
  ]
}
```

## Monitoramento

### Métricas Nativas

```bash
# CPU e memória dos nodes
kubectl top nodes

# CPU e memória dos pods
kubectl top pods -A

# Ver eventos
kubectl get events -A --sort-by='.lastTimestamp'
```

### Integração com OCI Monitoring

```hcl
# Alarm para CPU alta
resource "oci_monitoring_alarm" "node_cpu" {
  display_name = "OKE Node High CPU"
  compartment_id = var.compartment_id
  
  metric_compartment_id = var.compartment_id
  namespace = "oci_computeagent"
  query = "CpuUtilization[1m].mean() > 80"
  severity = "CRITICAL"
  
  destinations = [var.notification_topic_id]
}
```

## Persistent Storage

### 1. Usar OCI Block Volume

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: oci-bv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
```

### 2. Usar OCI File Storage (NFS)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fss-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.0.0.x
    path: "/myshare"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fss-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  volumeName: fss-pv
```

## Ingress Controller

### 1. Instalar NGINX Ingress

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

### 2. Criar Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

## Segurança

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Pod Security Standards

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Auto-scaling

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Troubleshooting

### Pods não iniciam

```bash
# Ver status do pod
kubectl describe pod <pod-name>

# Ver logs
kubectl logs <pod-name>

# Ver eventos
kubectl get events --sort-by='.lastTimestamp'
```

### Nodes em NotReady

```bash
# Ver detalhes do node
kubectl describe node <node-name>

# SSH no node (se configurado)
ssh opc@<node-ip>
sudo journalctl -u kubelet
```

### LoadBalancer em Pending

```bash
# Verificar service
kubectl describe svc <service-name>

# Verificar se subnet_ids está correto
# Verificar security lists/NSGs
```

### ImagePullBackOff

```bash
# Verificar secret do OCIR
kubectl get secret ocir-secret -o yaml

# Recriar se necessário
kubectl create secret docker-registry ocir-secret \
  --docker-server=<region>.ocir.io \
  --docker-username='<tenancy>/<user>' \
  --docker-password='<token>'
```

## Estimativa de Custos

| Cluster Type | Nodes | Shape | Custo/Mês |
|--------------|-------|-------|-----------|
| **BASIC** | 3 | E4.Flex (1 OCPU, 16GB) | ~$100 |
| **ENHANCED** | 3 | E4.Flex (2 OCPU, 32GB) | ~$350 |
| **Production HA** | 6 | E4.Flex (4 OCPU, 64GB) | ~$1200 |

## Recursos Adicionais

- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Helm Charts](https://artifacthub.io/)
- [OCI Container Runtime](https://docs.oracle.com/en-us/iaas/Content/Container/home.htm)
