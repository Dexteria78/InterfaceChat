#!/bin/bash

echo "🚀 Démarrage du projet Chat DevOps en local"
echo "============================================"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Installation requise."
    echo "   Installation: sudo apt install docker.io docker-compose"
    exit 1
fi

# Vérifier Docker Compose (v1 ou v2)
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ Docker Compose n'est pas installé."
    echo "   Installation: sudo apt install docker-compose-v2"
    exit 1
fi

echo "✓ Docker et Docker Compose sont installés"

# Démarrer les services
echo ""
echo "📦 Construction des images Docker..."
$COMPOSE_CMD build

echo ""
echo "🚢 Démarrage des services..."
$COMPOSE_CMD up -d

echo ""
echo "⏳ Attente du démarrage des services..."
sleep 10

# Pull du modèle Ollama
echo ""
echo "🤖 Téléchargement du modèle TinyLlama (peut prendre 2-3 minutes)..."
docker exec chat-ollama ollama pull tinyllama 2>&1 | grep -E "(pulling|success|error)" || echo "En cours..."

echo ""
echo "✅ Application démarrée avec succès !"
echo ""
echo "📍 URLs d'accès:"
echo "   Frontend:    http://localhost:3000"
echo "   Backend API: http://localhost:5000"
echo "   Grafana:     http://localhost:3001 (admin/admin)"
echo "   Prometheus:  http://localhost:9090"
echo "   Ollama:      http://localhost:11434"
echo ""
echo "📊 Pour voir les logs: $COMPOSE_CMD logs -f"
echo "🛑 Pour arrêter:       $COMPOSE_CMD down"
