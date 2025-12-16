# 🚀 Chat DevOps - Full Stack AI Chat Application

<div align="center">

![Status](https://img.shields.io/badge/Status-Production-success)
![Azure](https://img.shields.io/badge/Azure-AKS-0078D4)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestrated-326CE5)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF)

**Application de chat intelligente avec IA (TinyLlama), déployée sur Azure Kubernetes Service avec un pipeline DevOps complet.**

[🌐 Demo Live](http://4.178.25.91) | [📊 Monitoring](http://4.178.145.159:3000) | [📖 Documentation](#documentation)

</div>

---

## 📋 Table des Matières

- [🎯 Vue d'Ensemble](#-vue-densemble)
- [🏗️ Architecture](#️-architecture)
- [⚡ Technologies](#-technologies)
- [🚀 Démarrage Rapide](#-démarrage-rapide)
- [📊 Monitoring](#-monitoring)
- [🔄 CI/CD](#-cicd)
- [☁️ Infrastructure Azure](#️-infrastructure-azure)
- [🔒 Sécurité](#-sécurité)
- [📝 Documentation Complète](#-documentation-complète)

---

## 🎯 Vue d'Ensemble

Chat DevOps est une application de chat moderne avec intelligence artificielle intégrée (modèle TinyLlama via Ollama), démontrant les meilleures pratiques DevOps modernes :

### ✨ Fonctionnalités

- **💬 Chat en Temps Réel** : WebSocket pour communication instantanée
- **🤖 IA Intégrée** : Réponses automatiques via TinyLlama (637MB)
- **📊 Monitoring Complet** : Prometheus + Grafana avec dashboards personnalisés
- **🔄 CI/CD Automatisé** : Pipeline GitHub Actions avec 6 stages
- **☁️ Cloud Native** : Déployé sur Azure Kubernetes Service (AKS)
- **🔒 Sécurité** : Scans Trivy, OWASP, gestion des secrets via Azure Key Vault
- **📈 Scalabilité** : Autoscaling horizontal (HPA) et LoadBalancer
- **🐳 Containerisé** : Docker multi-stage builds optimisés

### 🌐 URLs de Production

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://4.178.25.91 | - |
| **Backend API** | http://4.251.128.52:5000 | - |
| **Grafana** | http://4.178.145.159:3000 | admin / admin123 |
| **Prometheus** | NodePort (via AKS nodes) | - |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     UTILISATEURS                            │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────▼─────────────┐
        │  Azure Load Balancer     │
        │  (Frontend: 4.178.25.91) │
        └────────────┬─────────────┘
                     │
     ┌───────────────┴──────────────┐
     │                              │
┌────▼─────┐                  ┌────▼─────┐
│ Frontend │                  │ Frontend │
│   Pod 1  │                  │   Pod 2  │
│  React   │                  │  React   │
│  + Nginx │                  │  + Nginx │
└────┬─────┘                  └────┬─────┘
     │                              │
     │        WebSocket + HTTP      │
     │                              │
     └──────────────┬───────────────┘
                    │
        ┌───────────▼────────────┐
        │ Backend LoadBalancer   │
        │ (API: 4.251.128.52)    │
        └───────────┬────────────┘
                    │
     ┌──────────────┴─────────────┐
     │                            │
┌────▼─────┐                ┌────▼─────┐
│ Backend  │                │ Backend  │
│  Pod 1   │                │  Pod 2   │
│ Node.js  │                │ Node.js  │
│ + WebWS  │                │ + WebWS  │
└────┬─────┘                └────┬─────┘
     │                            │
     └──────────┬─────────────────┘
                │ HTTP
                │
         ┌──────▼───────┐
         │    Ollama    │
         │   TinyLlama  │
         │   (637MB)    │
         └──────┬───────┘
                │
         ┌──────▼───────────────────┐
         │  Monitoring & Observability │
         ├─────────────────────────────┤
         │  • Prometheus (Metrics)     │
         │  • Grafana (Dashboards)     │
         │  • Azure Monitor            │
         └─────────────────────────────┘
```

### 🧱 Composants Principaux

#### **Frontend** (React 18)
- Interface utilisateur moderne et réactive
- WebSocket pour communication temps réel
- Build optimisé avec Nginx pour serving statique
- Health checks et readiness probes

#### **Backend** (Node.js 18 + Express)
- API RESTful pour gestion des messages
- WebSocket Server pour temps réel
- Intégration Ollama pour réponses IA
- Métriques Prometheus exposées sur `/metrics`

#### **Ollama + TinyLlama**
- Modèle LLM léger (637MB)
- Réponses en français optimisées
- Configuration de température et tokens adaptée
- Fallback en cas d'erreur

#### **Monitoring Stack**
- **Prometheus** : Collecte de métriques (messages, temps de réponse, CPU, RAM)
- **Grafana** : Dashboards avec 6 panneaux de visualisation
- **Azure Monitor** : Intégration native AKS

---

## ⚡ Technologies

### **Frontend**
- React 18.3
- WebSocket API
- CSS3 (Moderne UI)
- Nginx (Alpine)

### **Backend**
- Node.js 18
- Express 4
- ws (WebSocket)
- Axios
- prom-client (Prometheus)
- cors

### **Infrastructure**
- **Cloud**: Azure (AKS, ACR, Key Vault)
- **Orchestration**: Kubernetes 1.33.5
- **Packaging**: Helm 3
- **IaC**: Terraform 1.5+
- **CI/CD**: GitHub Actions
- **Containers**: Docker + Docker Compose

### **Monitoring**
- Prometheus
- Grafana
- Azure Monitor
- Application Insights (optionnel)

### **Sécurité**
- Trivy (Vulnerability scanning)
- OWASP Dependency Check
- Snyk (Code analysis)
- Azure Key Vault

---

## 🚀 Démarrage Rapide

### **Prérequis**

```bash
# Outils requis
- Docker 20+ & Docker Compose
- Node.js 18+
- kubectl
- helm 3+
- Azure CLI
- Terraform 1.5+
```

### **1️⃣ Déploiement Local (Docker Compose)**

```bash
# Cloner le repo
git clone https://github.com/Dexteria78/InterfaceChat.git
cd InterfaceChat

# Lancer tous les services
docker-compose up -d

# Accéder à l'application
open http://localhost:3000

# Monitorer les logs
docker-compose logs -f backend
```

**Services locaux :**
- Frontend : http://localhost:3000
- Backend : http://localhost:5000
- Ollama : http://localhost:11434
- Prometheus : http://localhost:9090
- Grafana : http://localhost:3001 (admin/admin)

### **2️⃣ Déploiement sur Azure (Production)**

#### **Étape A : Infrastructure Terraform**

```bash
cd terraform

# Initialiser Terraform
terraform init

# Créer l'infrastructure
terraform plan -out=tfplan
terraform apply tfplan

# Ressources créées :
# - Resource Group : rg-chat-devops
# - AKS Cluster : aks-chat-devops (2 nodes B2s_v2)
# - Container Registry : acrchatdevops.azurecr.io
# - Key Vault : kv-chat-devops
```

#### **Étape B : Configuration Kubernetes**

```bash
# Connecter kubectl à AKS
az aks get-credentials --resource-group rg-chat-devops --name aks-chat-devops

# Connecter ACR à AKS
az aks update -n aks-chat-devops -g rg-chat-devops --attach-acr acrchatdevops

# Créer le namespace
kubectl create namespace production
```

#### **Étape C : Build & Push Images**

```bash
# Login ACR
az acr login --name acrchatdevops

# Build Backend
docker build -t acrchatdevops.azurecr.io/chat-backend:latest ./backend
docker push acrchatdevops.azurecr.io/chat-backend:latest

# Build Frontend (avec variables d'environnement)
docker build \
  --build-arg REACT_APP_API_URL=http://4.251.128.52:5000 \
  --build-arg REACT_APP_WS_URL=ws://4.251.128.52:5000 \
  -t acrchatdevops.azurecr.io/chat-frontend:latest \
  ./frontend
docker push acrchatdevops.azurecr.io/chat-frontend:latest
```

#### **Étape D : Déploiement Helm**

```bash
# Déployer l'application complète
helm upgrade --install chat-app ./helm/chat-app \
  --namespace production \
  --create-namespace \
  --wait

# Vérifier le déploiement
kubectl get all -n production

# Obtenir les IPs publiques
kubectl get svc -n production
```

#### **Étape E : Charger le modèle Ollama**

```bash
# Trouver le pod Ollama
kubectl get pods -n production | grep ollama

# Télécharger TinyLlama
kubectl exec -n production <ollama-pod-name> -- ollama pull tinyllama

# Vérifier
kubectl exec -n production <ollama-pod-name> -- ollama list
```

---

## 📊 Monitoring

### **Grafana Dashboards**

Accès : http://4.178.145.159:3000 (admin / admin123)

**Dashboard "Chat DevOps Dashboard" inclut :**

1. **Total Messages** : Compteur global de messages
2. **Messages par Type** : user / bot / bot_fallback
3. **Ollama Response Time** : 95th percentile
4. **Backend CPU Usage** : Utilisation CPU par pod
5. **Backend Memory Usage** : RAM par pod
6. **Pod Status** : État des pods Kubernetes

### **Prometheus Queries**

```promql
# Nombre total de messages
sum(chat_messages_total)

# Taux de messages par seconde
rate(chat_messages_total[5m])

# Temps de réponse Ollama (p95)
histogram_quantile(0.95, rate(ollama_response_duration_seconds_bucket[5m]))

# CPU usage backend
rate(container_cpu_usage_seconds_total{pod=~".*backend.*"}[5m])

# Memory usage
container_memory_usage_bytes{pod=~".*backend.*"}
```

### **Azure Monitor**

Intégration automatique avec :
- Container Insights
- Log Analytics Workspace
- Application Insights (via instrumentation)

---

## 🔄 CI/CD

### **Pipeline GitHub Actions**

**Fichier** : `.github/workflows/ci-cd-complete.yml`

**6 Stages du Pipeline :**

```
┌────────────────────┐
│  0. CODE QUALITY   │  ESLint, SonarCloud
├────────────────────┤
│  1. BUILD & PUSH   │  Docker → ACR
├────────────────────┤
│  2. TESTS          │  Unit + Integration
├────────────────────┤
│  3. SECURITY       │  Trivy, Snyk, OWASP
├────────────────────┤
│  4. DEPLOY         │  Helm → AKS
├────────────────────┤
│  5. POST-DEPLOY    │  Smoke Tests, E2E
└────────────────────┘
```

### **Secrets GitHub requis**

```yaml
AZURE_CREDENTIALS: |-
  {
    "clientId": "...",
    "clientSecret": "...",
    "subscriptionId": "0e998d5e-35d5-4aeb-9c58-8732269b0bbd",
    "tenantId": "..."
  }

BACKEND_URL: "http://4.251.128.52:5000"
WS_URL: "ws://4.251.128.52:5000"

# Optionnels
SONAR_TOKEN: "..."
SNYK_TOKEN: "..."
SLACK_WEBHOOK: "..."
```

### **Déclencheurs**

- **Push sur `main`** → Déploiement Production
- **Push sur `develop`** → Déploiement Staging
- **Pull Request** → Tests uniquement
- **Manuel** → `workflow_dispatch`

### **Features CI/CD**

✅ Build parallèle (Backend + Frontend)
✅ Cache NPM et Docker layers
✅ Tests avec coverage (Codecov)
✅ Security scans (Trivy + Snyk + OWASP)
✅ Smoke tests post-déploiement
✅ Rollback automatique en cas d'échec
✅ Notifications Slack
✅ Cleanup automatique des vieilles images

---

## ☁️ Infrastructure Azure

### **Ressources Créées**

| Ressource | Type | Région | SKU |
|-----------|------|--------|-----|
| **rg-chat-devops** | Resource Group | France Central | - |
| **aks-chat-devops** | AKS Cluster | France Central | 2 × Standard_B2s_v2 |
| **acrchatdevops** | Container Registry | France Central | Basic |
| **kv-chat-devops** | Key Vault | France Central | Standard |

### **Coûts Estimés (Azure for Students)**

```
AKS (2 nodes B2s_v2)   : ~60€/mois
ACR Basic              : Gratuit (1 repo inclus)
Key Vault              : ~1€/mois
LoadBalancers (×3)     : ~15€/mois chacun
──────────────────────────────────────
Total estimé          : ~100-120€/mois
```

### **Terraform Outputs**

```bash
terraform output

# Outputs disponibles :
# - aks_cluster_name
# - acr_login_server
# - resource_group_name
# - key_vault_name
```

---

## 🔒 Sécurité

### **Mesures Implémentées**

✅ **Scan de Vulnérabilités** : Trivy dans le pipeline CI/CD
✅ **Secrets Management** : Azure Key Vault pour credentials
✅ **Network Policies** : Isolation des pods (à configurer)
✅ **RBAC** : Service Accounts Kubernetes avec permissions limitées
✅ **Image Signing** : Possibilité d'activer Cosign
✅ **OWASP** : Dependency Check automatique
✅ **HTTPS** : Possibilité d'activer avec cert-manager (Let's Encrypt)

### **Configuration Recommandée (Production)**

```bash
# Activer HTTPS avec cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace

# Configurer Network Policies
kubectl apply -f k8s/network-policies.yaml

# Scanner régulièrement
trivy image acrchatdevops.azurecr.io/chat-backend:latest
```

---

## 📝 Documentation Complète

### **Structure du Projet**

```
chat-devops-project/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml                  # Pipeline GitHub Actions (original)
│       ├── ci-cd-complete.yml         # Pipeline complet avec toutes les features
│       └── build-and-push-acr.yml     # Build et push vers ACR
├── backend/
│   ├── server.js                      # API Express + WebSocket
│   ├── package.json
│   ├── Dockerfile                     # Multi-stage build optimisé
│   └── .dockerignore
├── frontend/
│   ├── src/
│   │   ├── App.js                     # Composant React principal
│   │   └── App.css
│   ├── public/
│   ├── package.json
│   ├── Dockerfile                     # Build React + Nginx
│   └── nginx.conf                     # Configuration Nginx
├── helm/
│   └── chat-app/
│       ├── Chart.yaml
│       ├── values.yaml                # Valeurs par défaut
│       └── templates/
│           ├── _helpers.tpl           # Template helpers
│           ├── backend.yaml           # Deployment + Service Backend
│           ├── frontend.yaml          # Deployment + Service Frontend
│           ├── ollama.yaml            # Deployment Ollama + PVC
│           ├── prometheus-deployment.yaml
│           ├── prometheus-config.yaml
│           ├── grafana-deployment.yaml
│           ├── grafana-config.yaml
│           ├── hpa.yaml               # Horizontal Pod Autoscaler
│           └── ingress.yaml           # Ingress (optionnel)
├── terraform/
│   ├── main.tf                        # Configuration principale
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
├── ansible/
│   ├── playbook.yml                   # Playbook Ansible (si utilisé)
│   └── inventory.ini
├── docker-compose.yml                  # Orchestration locale
├── README.md                           # Ce fichier
└── LICENSE
```

### **Commandes Utiles**

```bash
# ═══════════════════════════════════════════════════════
# DÉVELOPPEMENT LOCAL
# ═══════════════════════════════════════════════════════

# Démarrer tous les services
docker-compose up -d

# Voir les logs en temps réel
docker-compose logs -f

# Arrêter et nettoyer
docker-compose down -v

# Rebuild après modifications
docker-compose up -d --build

# ═══════════════════════════════════════════════════════
# KUBERNETES (PRODUCTION)
# ═══════════════════════════════════════════════════════

# Pods
kubectl get pods -n production
kubectl logs -f <pod-name> -n production
kubectl describe pod <pod-name> -n production
kubectl exec -it <pod-name> -n production -- /bin/sh

# Services
kubectl get svc -n production
kubectl describe svc chat-app-frontend -n production

# Déploiements
kubectl get deployments -n production
kubectl rollout status deployment/chat-app-backend -n production
kubectl rollout restart deployment/chat-app-backend -n production

# Helm
helm list -n production
helm history chat-app -n production
helm rollback chat-app <revision> -n production

# HPA
kubectl get hpa -n production
kubectl describe hpa chat-app-backend-hpa -n production

# ═══════════════════════════════════════════════════════
# MONITORING
# ═══════════════════════════════════════════════════════

# Forward Grafana localement (si besoin)
kubectl port-forward -n production svc/chat-app-grafana 3000:3000

# Forward Prometheus
kubectl port-forward -n production svc/chat-app-prometheus 9090:9090

# Métriques backend directement
curl http://4.251.128.52:5000/metrics

# ═══════════════════════════════════════════════════════
# DEBUGGING
# ═══════════════════════════════════════════════════════

# Vérifier les événements
kubectl get events -n production --sort-by='.lastTimestamp'

# Vérifier la configuration
kubectl get configmap -n production
kubectl describe configmap chat-app-prometheus-config -n production

# Tester la connectivité interne
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n production -- \
  curl http://chat-app-backend:5000/api/health
```

---

## 🎓 Documentation Pédagogique

### **Points Clés pour le TP**

1. **Architecture Microservices** ✅
   - Frontend, Backend, AI séparés
   - Communication via API REST + WebSocket

2. **Containerisation** ✅
   - Docker multi-stage builds
   - Optimisation des images (Alpine Linux)
   - docker-compose pour orchestration locale

3. **Orchestration Kubernetes** ✅
   - Deployments avec replicas
   - Services (ClusterIP + LoadBalancer)
   - HPA (Horizontal Pod Autoscaler)
   - ConfigMaps et Secrets

4. **Infrastructure as Code** ✅
   - Terraform pour Azure
   - Helm Charts pour Kubernetes
   - GitOps avec versioning

5. **CI/CD** ✅
   - Pipeline multi-stages
   - Tests automatisés
   - Security scans
   - Déploiement automatique

6. **Monitoring & Observability** ✅
   - Prometheus pour métriques
   - Grafana pour visualisation
   - Logs centralisés

7. **Cloud Native** ✅
   - Scalabilité horizontale
   - Health checks
   - Rolling updates
   - Self-healing

### **Améliorations Possibles**

- [ ] Ajouter Ingress Controller (nginx-ingress) avec HTTPS
- [ ] Implémenter cert-manager pour Let's Encrypt
- [ ] Ajouter des tests E2E (Playwright, Cypress)
- [ ] Configurer Network Policies
- [ ] Ajouter EFK Stack (Elasticsearch, Fluentd, Kibana) pour logs
- [ ] Implémenter Chaos Engineering (Chaos Mesh)
- [ ] Ajouter un service mesh (Istio, Linkerd)
- [ ] Implémenter GitOps avec ArgoCD ou Flux

---

## 📄 License

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👨‍💻 Auteur

**Dexteria78**

- GitHub : [@Dexteria78](https://github.com/Dexteria78)
- Projet : [InterfaceChat](https://github.com/Dexteria78/InterfaceChat)

---

## 🙏 Remerciements

- **Ollama** pour le framework LLM
- **TinyLlama** pour le modèle compact
- **Azure** pour l'infrastructure cloud
- **Prometheus & Grafana** pour le monitoring
- **Kubernetes** pour l'orchestration

---

<div align="center">

**⭐ Si ce projet vous a aidé, n'hésitez pas à lui donner une étoile ! ⭐**

Made with ❤️ for DevOps learning

</div>
