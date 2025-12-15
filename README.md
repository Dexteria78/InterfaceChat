# 💬 Interface Chat DevOps

Interface de chat moderne avec IA (TinyLlama) déployée avec une stack DevOps complète.

## 🚀 Technologies

- **Frontend**: React 18 + WebSocket
- **Backend**: Node.js 18 + Express
- **IA**: Ollama + TinyLlama
- **Conteneurisation**: Docker + Docker Compose
- **Orchestration**: Kubernetes + Helm
- **Infrastructure**: Terraform (Azure AKS)
- **Configuration**: Ansible
- **CI/CD**: GitLab CI/CD
- **Monitoring**: Prometheus + Grafana
- **Sécurité**: Trivy + OWASP ZAP

## ⚡ Démarrage rapide (Local)

```bash
# Lancer tous les services
./start-local.sh

# Accéder à l'application
# Frontend: http://localhost:3000
# Backend: http://localhost:5000
# Grafana: http://localhost:3001 (admin/admin)
# Prometheus: http://localhost:9090
```

## 🛑 Arrêter les services

```bash
./stop-local.sh
```

## 📊 Services disponibles

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Interface de chat |
| Backend | http://localhost:5000 | API REST + WebSocket |
| Ollama | http://localhost:11434 | Serveur IA TinyLlama |
| Grafana | http://localhost:3001 | Dashboards monitoring |
| Prometheus | http://localhost:9090 | Métriques |

## 🏗️ Architecture

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   React     │◄────►│   Node.js   │◄────►│   Ollama    │
│  Frontend   │      │   Backend   │      │  TinyLlama  │
└─────────────┘      └─────────────┘      └─────────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ Prometheus  │
                     │  Grafana    │
                     └─────────────┘
```

## 📦 Structure du projet

```
.
├── backend/              # API Node.js + Ollama
├── frontend/             # Interface React
├── monitoring/           # Prometheus + Grafana
├── terraform/            # Infrastructure Azure
├── ansible/              # Playbooks déploiement
├── helm/                 # Charts Kubernetes
├── docker-compose.yml    # Orchestration Docker
├── .gitlab-ci.yml        # Pipeline CI/CD
└── start-local.sh        # Script de démarrage
```

## 🔐 CI/CD Pipeline

Le pipeline GitLab CI/CD automatise :
- **Build** : Images Docker → Azure Container Registry
- **Test** : Tests unitaires automatiques
- **Security** : Scans Trivy + OWASP ZAP
- **Deploy** : Helm sur AKS (staging auto, prod manuel)

## ☁️ Déploiement Azure

```bash
# 1. Infrastructure Terraform
cd terraform
terraform init
terraform apply

# 2. Configuration Kubernetes
az aks get-credentials --resource-group rg-chat-devops --name aks-chat-devops

# 3. Déploiement Helm
helm install chat-app ./helm/chat-app
```

## 📈 Monitoring

Dashboard Grafana pré-configuré avec :
- Status des services
- Nombre de messages
- Temps de réponse IA
- CPU/Mémoire backend

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amazing`)
3. Commit (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing`)
5. Ouvrir une Pull Request

## 📝 Licence

MIT

## 👤 Auteur

**Dexteria78**
