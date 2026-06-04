#!/bin/bash
# Phase 5: Deploy all containers
set -euo pipefail

DOCKER_CONFIG=/opt/docker
ENV_FILE=$DOCKER_CONFIG/.env

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: $ENV_FILE not found. Copy .env.example and fill in values first."
  exit 1
fi

echo "=== Starting Jellyfin ==="
docker compose -f $DOCKER_CONFIG/docker-compose.jellyfin.yml --env-file $ENV_FILE up -d

echo "=== Starting FileFlows ==="
docker compose -f $DOCKER_CONFIG/docker-compose.fileflows.yml --env-file $ENV_FILE up -d

echo "=== Starting Proxy Stack ==="
docker compose -f $DOCKER_CONFIG/docker-compose.proxy.yml --env-file $ENV_FILE up -d

echo ""
echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✓ All containers started."
echo ""
echo "Services available locally:"
echo "  Jellyfin:            http://localhost:8096"
echo "  FileFlows:           http://localhost:5000"
echo "  Nginx Proxy Manager: http://localhost:81"
echo "  Authelia:            http://localhost:9091"
