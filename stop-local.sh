#!/bin/bash

# Détecter Docker Compose v1 ou v2
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "🛑 Arrêt des services..."
$COMPOSE_CMD down

echo "🧹 Nettoyage des volumes (optionnel)..."
read -p "Voulez-vous supprimer les volumes ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    $COMPOSE_CMD down -v
    echo "✓ Volumes supprimés"
fi

echo "✅ Services arrêtés"
