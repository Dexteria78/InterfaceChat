#  Chat DevOps - Full Stack IA (chatbox)

##  Important
Réalisé par: Jovany, Nassim, Ruchebe, Nicolas
Le budget pour azure à été dépassé donc l'application ne fonctionne plus sur azure mais la CI/CD montre bien que l'applcation sur azure a fonctionné plusieurs semaines (à voir le healthcheck) 

###  Fonctionnalités

- ** Chat en Temps Réel** : WebSocket pour communication instantanée
- ** IA Intégrée** : Réponses automatiques via TinyLlama (637MB)
- ** Monitoring Complet** : Prometheus + Grafana avec dashboards personnalisés
- ** CI/CD Automatisé** : Pipeline GitHub Actions avec 6 stages
- ** Cloud Native** : Déployé sur Azure Kubernetes Service (AKS)
- ** Sécurité** : Scans Trivy, OWASP, gestion des secrets via Azure Key Vault
- ** Scalabilité** : Autoscaling horizontal (HPA) et LoadBalancer
- ** Containerisé** : Docker multi-stage builds optimisés

###  URLs de Production

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://4.178.25.91 | - |
| **Backend API** | http://4.251.128.52:5000 | - |
| **Grafana** | http://4.178.145.159:3000 | admin / admin123 |
| **Prometheus** | NodePort (via AKS nodes) | - |

---

## Technologies

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


### **Déploiement Local (Docker Compose)**

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

### ** Déploiement sur Azure **

#### **Étape A : Infrastructure Terraform**
#### **Étape B : Configuration Kubernetes**
#### **Étape C : Build & Push Images**
#### **Étape D : Déploiement Helm**
#### **Étape E : Charger le modèle Ollama**


##  Monitoring

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


#### 1. **CI/CD Complet avec Monitoring Azure** 

**Jobs Détaillés :**

1. **Analyse de la Qualité du Code**
   - Linter ESLint (backend + frontend)
   - npm audit (détection vulnérabilités)
   - Analyse de sécurité des dépendances

2. **Tests Unitaires et d'Intégration**
   - Tests backend (Jest/Mocha)
   - Tests frontend (React Testing Library)
   - Couverture de code

3. **Construction et Push des Images Docker**
   - Build multi-stage optimisé
   - Tagging : `{timestamp}-{sha7}` + `latest`
   - Push vers Azure Container Registry
   - Scan de sécurité Trivy (HIGH/CRITICAL)

4. **Déploiement en Staging**
   - Namespace dédié `staging`
   - Replicas réduits (1 backend, 1 frontend)
   - Tests de fumée automatiques
   - Validation HTTP/WebSocket

5. **Déploiement en Production**
   - **Uniquement sur branche `main`**
   - Backup automatique de la config
   - Déploiement Blue-Green
   - Replicas production (3 backend, 2 frontend)
   - Health checks complets

6. **Configuration du Monitoring Azure**
   - Activation Azure Monitor pour Containers
   - Création d'alertes (CPU > 80%, Memory > 85%)
   - Configuration Application Insights
   - Vérification Prometheus + Grafana

7. **Notification de Déploiement**
   - Résumé complet du pipeline
   - Tags des images déployées
   - Liens vers les environnements
   - Statut du monitoring
     

#### 2. **Surveillance Continue et Health Checks**
 `.github/workflows/monitoring-health-check.yml`

Vérifications automatiques **toutes les jours** :

**Jobs de Surveillance :**

- **Vérification de la Santé des Services** 
  - État des pods (Running/NotRunning)
  - Tests HTTP frontend (4.178.25.91)
  - Tests API backend (/api/health)
  - Tests WebSocket (connexion Upgrade)
  - Vérification Ollama (modèles disponibles)
  - Vérification Prometheus (healthy)
  - Vérification Grafana (API health)

- **Collecte des Métriques de Ressources** 
  - `kubectl top pods` et `kubectl top nodes`
  - Métriques Azure Monitor (CPU cluster)
  - Espace disque des PVC
  - Utilisation RAM/CPU par pod

- **Analyse des Logs et Erreurs** 
  - Recherche d'erreurs dans logs backend
  - Recherche d'erreurs dans logs frontend
  - Événements Kubernetes récents
  - Détection des redémarrages de pods

- **Rapport de Monitoring** 
  - Statut de chaque service
  - Alertes en cas de problèmes
  - Liens rapides vers les dashboards


###  Configuration des Secrets GitHub

Secrets requis dans **Settings → Secrets → Actions** :

```yaml
ACR_USERNAME: acrchatdevops
ACR_PASSWORD: <from Azure Portal>
AZURE_CREDENTIALS: <JSON from 'az ad sp create-for-rbac'>
AZURE_SUBSCRIPTION_ID: 0e998d5e-35d5-4aeb-9c58-8732269b0bbd
```


**Vérifications effectuées :**
1.  Connexion Azure
2.  État du cluster AKS
3.  État des nodes Kubernetes
4.  État des pods (Running/NotRunning)
5.  Utilisation ressources (CPU/RAM)
6.  Test frontend HTTP
7.  Test API backend
8.  Test Grafana
9.  Test Prometheus
10.  Test Ollama + modèles


###  Dashboards de Monitoring

**1. Grafana (Production)**
- URL : http://4.178.145.159:3000
- User : `admin` / Pass : `admin`
- Dashboards :
  - Application Overview
  - Backend Metrics
  - Frontend Metrics
  - Infrastructure Health
  - WebSocket Connections

**2. Prometheus**
- URL : http://<node-ip>:32269
- Métriques disponibles :
  - `http_requests_total` - Compteur requêtes
  - `http_request_duration_seconds` - Latence
  - `websocket_connections` - Connexions WS
  - `ollama_requests_total` - Requêtes IA
  - `node_*` et `pod_*` - Métriques système

**3. Azure Monitor**
- Portal : https://portal.azure.com
- Container Insights actif
- Logs Analytics workspace
- Métriques en temps réel


###  Métriques de Performance du Pipeline

###  Bonnes Pratiques Implémentées

 **Tests Automatisés** : Linting + Tests unitaires + Smoke tests  
 **Sécurité** : Scan Trivy + npm audit + RBAC Kubernetes  
 **Qualité** : ESLint + Prettier + Revue de code obligatoire  
 **Monitoring** : Prometheus + Grafana + Azure Monitor  
 **Rollback** : Automatique avec Helm (< 2 min)  
 **Blue-Green** : Déploiement sans downtime  
 **Secrets** : GitHub Secrets + Azure Key Vault  
 **Documentation** : README + Commentaires + Workflows en français

### **Features CI/CD**

 Build parallèle (Backend + Frontend)
 Cache NPM et Docker layers
 Tests avec coverage (Codecov)
 Security scans (Trivy + Snyk + OWASP)
 Smoke tests post-déploiement
 Rollback automatique en cas d'échec
 Notifications Slack
 Cleanup automatique des vieilles images

---

##  Infrastructure Azure

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

### **Terraform**

```bash
terraform output

# Outputs disponibles :
# - aks_cluster_name
# - acr_login_server
# - resource_group_name
# - key_vault_name
```

---

##  Sécurité

### **Mesures Implémentées**

 **Scan de Vulnérabilités** : Trivy dans le pipeline CI/CD
 **Secrets Management** : Azure Key Vault pour credentials
 **Network Policies** : Isolation des pods (à configurer)
 **RBAC** : Service Accounts Kubernetes avec permissions limitées
 **Image Signing** : Possibilité d'activer Cosign
 **OWASP** : Dependency Check automatique
 **HTTPS** : Possibilité d'activer avec cert-manager (Let's Encrypt)

---

##  Documentation


1. **Architecture Microservices** 
   - Frontend, Backend, AI séparés
   - Communication via API REST + WebSocket

2. **Containerisation** 
   - Docker multi-stage builds
   - Optimisation des images (Alpine Linux)
   - docker-compose pour orchestration locale

3. **Orchestration Kubernetes** 
   - Deployments avec replicas
   - Services (ClusterIP + LoadBalancer)
   - HPA (Horizontal Pod Autoscaler)
   - ConfigMaps et Secrets

4. **Infrastructure as Code** 
   - Terraform pour Azure
   - Helm Charts pour Kubernetes
   - GitOps avec versioning

5. **CI/CD** 
   - Pipeline multi-stages
   - Tests automatisés
   - Security scans
   - Déploiement automatique

6. **Monitoring & Observability** 
   - Prometheus pour métriques
   - Grafana pour visualisation
   - Logs centralisés

7. **Cloud Native** 
   - Scalabilité horizontale
   - Health checks
   - Rolling updates
   - Self-healing


