# 🔄 GitHub Actions CI/CD

Ce projet utilise **GitHub Actions** pour l'intégration et le déploiement continu.

## 📋 Pipeline Automatisé

Le workflow se déclenche automatiquement sur :
- Push vers `main` ou `develop`
- Pull Requests vers `main` ou `develop`

## 🎯 Stages du Pipeline

### 1️⃣ BUILD (Construction)
- **build-backend** : Construit et push l'image Docker backend
- **build-frontend** : Construit et push l'image Docker frontend
- Images stockées dans GitHub Container Registry (ghcr.io)
- Tags : branch name, commit SHA, latest

### 2️⃣ TEST (Tests)
- **test-backend** : Exécute les tests backend (npm test)
- **test-frontend** : Exécute les tests frontend (npm test)
- Node.js 18 avec cache npm

### 3️⃣ SECURITY (Sécurité)
- **security-scan-backend** : Scan Trivy des vulnérabilités backend
- **security-scan-frontend** : Scan Trivy des vulnérabilités frontend
- **owasp-zap-scan** : Tests de sécurité web (uniquement sur main)
- Résultats envoyés dans GitHub Security

### 4️⃣ DEPLOY (Déploiement)
- **deploy-staging** : Déploiement auto sur `develop` → namespace staging
- **deploy-production** : Déploiement auto sur `main` → namespace production
- Utilise Helm pour déployer sur Azure AKS

## 🔐 Secrets Requis

À configurer dans : **Settings → Secrets and variables → Actions**

### AZURE_CREDENTIALS
Service Principal Azure au format JSON :
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Pour créer ce secret :
```bash
az ad sp create-for-rbac \
  --name "github-actions-chat-devops" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-chat-devops \
  --sdk-auth
```

### GITHUB_TOKEN
Automatiquement fourni par GitHub Actions (pas besoin de le créer)

## 📊 Workflow Complet

### Branch `develop` (Développement)
```
Push → Build → Test → Security → Deploy Staging ✅
```

### Branch `main` (Production)
```
Push → Build → Test → Security → OWASP ZAP → Deploy Production ✅
```

## 🚀 Avantages GitHub Actions

✅ **Intégré** : Directement dans GitHub (pas besoin de GitLab)
✅ **Gratuit** : 2000 minutes/mois pour les repos publics
✅ **Visibilité** : Résultats de sécurité dans l'onglet "Security"
✅ **Container Registry** : Images stockées dans ghcr.io gratuitement
✅ **Environments** : Protection des branches et approbations

## 📈 Voir les Résultats

- **Actions** : Onglet "Actions" du repo GitHub
- **Security** : Onglet "Security" → Code scanning alerts
- **Packages** : Images Docker dans Packages du repo

## 🔄 Activer le Pipeline

Le pipeline est **déjà actif** ! Il se déclenchera automatiquement au prochain push.

Pour tester maintenant :
```bash
git commit --allow-empty -m "Test CI/CD pipeline"
git push origin main
```

Puis va dans l'onglet **Actions** pour voir le pipeline en cours d'exécution.
