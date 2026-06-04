#!/bin/bash
# Phase 7: Cloudflare Tunnel setup
set -euo pipefail

TUNNEL_NAME="mystudio-media"
DOMAIN="media.yourstudio.com"   # Change this to your domain

echo "=== Installing cloudflared CLI ==="
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
  -o /tmp/cloudflared.deb
sudo dpkg -i /tmp/cloudflared.deb

echo ""
echo "=== Login to Cloudflare (opens browser) ==="
cloudflared tunnel login

echo ""
echo "=== Creating tunnel: $TUNNEL_NAME ==="
cloudflared tunnel create "$TUNNEL_NAME"

TUNNEL_ID=$(cloudflared tunnel list --output json | python3 -c "
import json,sys
tunnels=json.load(sys.stdin)
for t in tunnels:
    if t['name']=='$TUNNEL_NAME':
        print(t['id'])
        break
")

echo "Tunnel ID: $TUNNEL_ID"

echo ""
echo "=== Writing tunnel config ==="
cat > /opt/docker/cloudflared/config.yml <<EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: http://nginx-proxy-manager:80
    originRequest:
      connectTimeout: 30s
      tcpKeepAlive: 30s
      keepAliveConnections: 100

  - hostname: admin.$(echo $DOMAIN | cut -d. -f2-)
    service: http://nginx-proxy-manager:81

  - service: http_status:404
EOF

echo "=== Adding DNS route ==="
cloudflared tunnel route dns "$TUNNEL_NAME" "$DOMAIN"

echo ""
echo "=== Getting tunnel token for Docker .env ==="
TOKEN=$(cloudflared tunnel token "$TUNNEL_ID")
echo ""
echo "Add this to /opt/docker/.env:"
echo "  CLOUDFLARE_TUNNEL_TOKEN=$TOKEN"
echo ""
echo "Then restart the proxy stack:"
echo "  docker compose -f /opt/docker/docker-compose.proxy.yml --env-file /opt/docker/.env up -d"
