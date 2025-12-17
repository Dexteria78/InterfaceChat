# Configuration de l'authentification Azure pour GitHub Actions

## 🔐 Options d'authentification

### Option 1 : OIDC (OpenID Connect) - Recommandé

OIDC permet une authentification sans secret, plus sécurisée.

#### Étapes :

1. **Créer un Service Principal avec les bonnes permissions** :
```bash
az ad sp create-for-rbac \
  --name "github-actions-chat-devops" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-chat-devops
```

2. **Récupérer les informations** :
```bash
# Afficher l'Application (client) ID
az ad sp list --display-name "github-actions-chat-devops" --query "[0].appId" -o tsv

# Tenant ID
az account show --query tenantId -o tsv

# Subscription ID
az account show --query id -o tsv
```

3. **Configurer les secrets GitHub** :

Aller sur : `https://github.com/Dexteria78/InterfaceChat/settings/secrets/actions`

Ajouter ces secrets :
- `AZURE_CLIENT_ID` : Application (client) ID
- `AZURE_TENANT_ID` : Tenant ID
- `AZURE_SUBSCRIPTION_ID` : Subscription ID

### Option 2 : Déploiement manuel (Temporaire)

Si tu n'as pas les permissions pour créer un Service Principal, tu peux déployer manuellement :

```bash
# Se connecter à Azure
az login

# Configurer kubectl pour AKS
az aks get-credentials --resource-group rg-chat-devops --name aks-chat-devops

# Déployer avec Helm
helm upgrade --install chat-app ./helm/chat-app \
  --namespace production \
  --set backend.image.tag=latest \
  --set frontend.image.tag=latest \
  --create-namespace
```

### Option 3 : Désactiver le déploiement automatique

Le workflow actuel est déjà configuré pour skip le déploiement si les secrets ne sont pas disponibles.

Les images Docker seront quand même construites et pushées vers Azure Container Registry (ACR).

## 📊 Statut actuel

✅ Build & Push vers ACR : Fonctionne
⚠️ Déploiement AKS : Nécessite la configuration des secrets
✅ Scans de sécurité : Fonctionnels

## 🔧 Pour tester

Après avoir configuré les secrets, push un commit pour déclencher le pipeline :

```bash
git commit --allow-empty -m "test: trigger pipeline with Azure auth"
git push origin main
```
