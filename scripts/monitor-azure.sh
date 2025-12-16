#!/bin/bash

# Script de monitoring pour Azure AKS et les services de l'application
# Ce script collecte les métriques et envoie des alertes si nécessaire

set -e

# Configuration
AKS_CLUSTER="aks-chat-devops"
RESOURCE_GROUP="rg-chat-devops"
NAMESPACE="production"
FRONTEND_IP="4.178.25.91"
GRAFANA_IP="4.178.145.159"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "   SURVEILLANCE AZURE - CHAT DEVOPS"
echo -e "========================================${NC}"
echo ""

# Fonction pour afficher le statut
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# 1. Vérification de la connexion Azure
echo -e "${BLUE}[1/10] Vérification de la connexion Azure...${NC}"
if az account show &>/dev/null; then
    SUBSCRIPTION=$(az account show --query name -o tsv)
    echo -e "${GREEN}✅ Connecté à: ${SUBSCRIPTION}${NC}"
else
    echo -e "${RED}❌ Non connecté à Azure. Exécutez: az login${NC}"
    exit 1
fi

# 2. État du cluster AKS
echo ""
echo -e "${BLUE}[2/10] État du cluster AKS...${NC}"
AKS_STATUS=$(az aks show -n $AKS_CLUSTER -g $RESOURCE_GROUP --query "provisioningState" -o tsv 2>/dev/null)
if [ "$AKS_STATUS" == "Succeeded" ]; then
    echo -e "${GREEN}✅ Cluster AKS: Opérationnel${NC}"
    
    # Informations supplémentaires
    NODE_COUNT=$(az aks show -n $AKS_CLUSTER -g $RESOURCE_GROUP --query "agentPoolProfiles[0].count" -o tsv)
    K8S_VERSION=$(az aks show -n $AKS_CLUSTER -g $RESOURCE_GROUP --query "currentKubernetesVersion" -o tsv)
    echo "   📊 Nodes: ${NODE_COUNT}"
    echo "   🔢 Version K8s: ${K8S_VERSION}"
else
    echo -e "${RED}❌ Cluster AKS: ${AKS_STATUS}${NC}"
fi

# 3. État des nodes Kubernetes
echo ""
echo -e "${BLUE}[3/10] État des nodes Kubernetes...${NC}"
kubectl get nodes -o wide 2>/dev/null || echo -e "${YELLOW}⚠️  Impossible de se connecter à kubectl${NC}"

# 4. État des pods
echo ""
echo -e "${BLUE}[4/10] État des pods en production...${NC}"
TOTAL_PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep "Running" | wc -l)

if [ $TOTAL_PODS -eq $RUNNING_PODS ]; then
    echo -e "${GREEN}✅ Tous les pods sont Running (${RUNNING_PODS}/${TOTAL_PODS})${NC}"
else
    echo -e "${YELLOW}⚠️  ${RUNNING_PODS}/${TOTAL_PODS} pods Running${NC}"
    kubectl get pods -n $NAMESPACE 2>/dev/null
fi

# 5. Utilisation des ressources (CPU/Mémoire)
echo ""
echo -e "${BLUE}[5/10] Utilisation des ressources...${NC}"
echo "Nodes:"
kubectl top nodes 2>/dev/null || echo -e "${YELLOW}⚠️  Metrics server non disponible${NC}"
echo ""
echo "Pods (Top 5):"
kubectl top pods -n $NAMESPACE --sort-by=cpu 2>/dev/null | head -6 || echo -e "${YELLOW}⚠️  Metrics server non disponible${NC}"

# 6. Test du frontend
echo ""
echo -e "${BLUE}[6/10] Test du frontend...${NC}"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${FRONTEND_IP}/ --max-time 10)
if [ "$FRONTEND_STATUS" == "200" ]; then
    echo -e "${GREEN}✅ Frontend accessible (HTTP ${FRONTEND_STATUS})${NC}"
    echo "   🔗 http://${FRONTEND_IP}"
else
    echo -e "${RED}❌ Frontend inaccessible (HTTP ${FRONTEND_STATUS})${NC}"
fi

# 7. Test de l'API backend
echo ""
echo -e "${BLUE}[7/10] Test de l'API backend...${NC}"
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=backend --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$BACKEND_POD" ]; then
    kubectl exec -n $NAMESPACE $BACKEND_POD -- wget -q -O- http://localhost:5000/api/health 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ API backend opérationnelle${NC}"
    else
        echo -e "${RED}❌ API backend ne répond pas${NC}"
    fi
else
    echo -e "${RED}❌ Aucun pod backend trouvé${NC}"
fi

# 8. Vérification de Grafana
echo ""
echo -e "${BLUE}[8/10] Vérification de Grafana...${NC}"
GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${GRAFANA_IP}:3000/api/health --max-time 10)
if [ "$GRAFANA_STATUS" == "200" ]; then
    echo -e "${GREEN}✅ Grafana accessible (HTTP ${GRAFANA_STATUS})${NC}"
    echo "   🔗 http://${GRAFANA_IP}:3000"
    echo "   👤 Identifiants par défaut: admin / admin"
else
    echo -e "${YELLOW}⚠️  Grafana: HTTP ${GRAFANA_STATUS}${NC}"
fi

# 9. Vérification de Prometheus
echo ""
echo -e "${BLUE}[9/10] Vérification de Prometheus...${NC}"
PROMETHEUS_POD=$(kubectl get pods -n $NAMESPACE -l app=prometheus --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$PROMETHEUS_POD" ]; then
    kubectl exec -n $NAMESPACE $PROMETHEUS_POD -- wget -q -O- http://localhost:9090/-/healthy 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Prometheus opérationnel${NC}"
        
        # Port NodePort
        PROM_PORT=$(kubectl get svc chat-app-prometheus -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        echo "   🔗 Port NodePort: ${PROM_PORT}"
    else
        echo -e "${RED}❌ Prometheus ne répond pas${NC}"
    fi
else
    echo -e "${RED}❌ Aucun pod Prometheus trouvé${NC}"
fi

# 10. Vérification d'Ollama
echo ""
echo -e "${BLUE}[10/10] Vérification d'Ollama...${NC}"
OLLAMA_POD=$(kubectl get pods -n $NAMESPACE -l app=ollama --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$OLLAMA_POD" ]; then
    OLLAMA_MODELS=$(kubectl exec -n $NAMESPACE $OLLAMA_POD -- ollama list 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Ollama opérationnel${NC}"
        echo "   📦 Modèles disponibles:"
        echo "$OLLAMA_MODELS" | tail -n +2 | while read line; do
            echo "      - $line"
        done
    else
        echo -e "${RED}❌ Ollama ne répond pas${NC}"
    fi
else
    echo -e "${RED}❌ Aucun pod Ollama trouvé${NC}"
fi

# Métriques Azure Monitor
echo ""
echo -e "${BLUE}[Bonus] Métriques Azure Monitor...${NC}"
echo "CPU du cluster (moyenne sur 5 min):"
az monitor metrics list \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ContainerService/managedClusters/${AKS_CLUSTER}" \
    --metric "node_cpu_usage_percentage" \
    --interval PT5M \
    --start-time $(date -u -d '10 minutes ago' '+%Y-%m-%dT%H:%M:%SZ') \
    --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
    --query "value[].timeseries[].data[-1].average" \
    --output tsv 2>/dev/null | awk '{printf "   %.2f%%\n", $1}' || echo -e "${YELLOW}   ⚠️  Données non disponibles${NC}"

# Événements récents
echo ""
echo -e "${BLUE}[Événements récents]${NC}"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' 2>/dev/null | tail -5

# Résumé final
echo ""
echo -e "${BLUE}========================================"
echo "           RÉSUMÉ DE LA SURVEILLANCE"
echo -e "========================================${NC}"
echo ""

HEALTH_SCORE=0

if [ "$AKS_STATUS" == "Succeeded" ]; then ((HEALTH_SCORE++)); fi
if [ $TOTAL_PODS -eq $RUNNING_PODS ]; then ((HEALTH_SCORE++)); fi
if [ "$FRONTEND_STATUS" == "200" ]; then ((HEALTH_SCORE++)); fi
if [ -n "$BACKEND_POD" ]; then ((HEALTH_SCORE++)); fi
if [ "$GRAFANA_STATUS" == "200" ]; then ((HEALTH_SCORE++)); fi

echo "📊 Score de santé: ${HEALTH_SCORE}/5"

if [ $HEALTH_SCORE -eq 5 ]; then
    echo -e "${GREEN}✅ TOUS LES SERVICES SONT OPÉRATIONNELS${NC}"
elif [ $HEALTH_SCORE -ge 3 ]; then
    echo -e "${YELLOW}⚠️  CERTAINS SERVICES NÉCESSITENT ATTENTION${NC}"
else
    echo -e "${RED}❌ PROBLÈMES CRITIQUES DÉTECTÉS${NC}"
fi

echo ""
echo "🔗 Liens rapides:"
echo "   - Application: http://${FRONTEND_IP}"
echo "   - Grafana: http://${GRAFANA_IP}:3000"
echo "   - Prometheus: http://<node-ip>:$(kubectl get svc chat-app-prometheus -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo '32269')"
echo ""
echo "📅 $(date)"
echo -e "${BLUE}========================================${NC}"
