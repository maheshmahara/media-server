#!/bin/bash
# Phase 4: Directory structure + permissions
set -euo pipefail

DOCKER_CONFIG=/opt/docker

echo "=== Creating Docker config directories ==="
sudo mkdir -p $DOCKER_CONFIG/{npm/{data,letsencrypt},authelia/config,cloudflared}
sudo mkdir -p /mediapool/cache/{jellyfin/{config,transcodes,cache},fileflows/{data,logs}}
sudo mkdir -p /mediapool/staging/{incoming,processing}
sudo mkdir -p /opt/scripts

echo "=== Setting ownership ==="
sudo chown -R mediaserver:mediaserver /mediapool/{clients,staging,cache,transcode_tmp}

echo "=== Setting permissions ==="
sudo chmod -R 755 /mediapool/clients
sudo chmod -R 775 /mediapool/staging/incoming

echo "=== Copying project files ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

sudo cp "$PROJECT_DIR"/docker/docker-compose.*.yml $DOCKER_CONFIG/
sudo cp "$PROJECT_DIR"/.env.example $DOCKER_CONFIG/.env.example
sudo cp -r "$PROJECT_DIR"/cloudflared/. $DOCKER_CONFIG/cloudflared/
sudo cp -r "$PROJECT_DIR"/authelia/. $DOCKER_CONFIG/authelia/
sudo cp "$PROJECT_DIR"/scripts/backup-media.sh /opt/scripts/
sudo chmod +x /opt/scripts/backup-media.sh

echo ""
echo "=== Creating Docker network ==="
docker network create media_net 2>/dev/null || echo "Network already exists."

echo ""
echo "✓ Directories and permissions set."
echo ""
echo "NEXT: Edit $DOCKER_CONFIG/.env with your real values:"
echo "  sudo cp $DOCKER_CONFIG/.env.example $DOCKER_CONFIG/.env"
echo "  sudo nano $DOCKER_CONFIG/.env"
echo "  sudo chmod 600 $DOCKER_CONFIG/.env"
