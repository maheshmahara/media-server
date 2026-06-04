#!/bin/bash
# Master deploy script — runs all phases in order
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_phase() {
  local name="$1"
  local script="$2"
  echo ""
  echo "══════════════════════════════════════════"
  echo "  $name"
  echo "══════════════════════════════════════════"
  bash "$SCRIPT_DIR/$script"
}

echo "╔══════════════════════════════════════════╗"
echo "║   Media Studio — Full Deployment         ║"
echo "╚══════════════════════════════════════════╝"

run_phase "Phase 1: Base OS + Docker"        "01-base-setup.sh"
run_phase "Phase 2: ZFS Storage"             "02-zfs-setup.sh"
run_phase "Phase 3: Intel QSV Drivers"       "03-qsv-setup.sh"
run_phase "Phase 4: Directories & Perms"     "04-dirs-and-permissions.sh"

echo ""
echo "══════════════════════════════════════════"
echo "  ACTION REQUIRED: Configure .env"
echo "══════════════════════════════════════════"
echo ""
echo "Before continuing, fill in /opt/docker/.env:"
echo "  sudo cp /opt/docker/.env.example /opt/docker/.env"
echo "  sudo nano /opt/docker/.env"
echo "  sudo chmod 600 /opt/docker/.env"
echo ""
read -p "Press ENTER when .env is ready..."

run_phase "Phase 5: Deploy Containers"       "05-deploy-containers.sh"
run_phase "Phase 6: Cloudflare Tunnel"       "06-cloudflare-tunnel.sh"
run_phase "Phase 7: Backup Setup"            "install-backup.sh"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  ✓ Deployment Complete!                  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Manual steps remaining:"
echo "  1. Browse to http://localhost:8096 — complete Jellyfin wizard"
echo "  2. Enable VAAPI: Dashboard → Playback → Transcoding"
echo "  3. Paste jellyfin-custom.css into Dashboard → General → Custom CSS"
echo "  4. Browse to http://localhost:81 — configure NPM proxy host"
echo "     Use: npm/jellyfin-proxy.conf in the Advanced tab"
echo "  5. Browse to http://localhost:5000 — configure FileFlows"
echo "  6. Create clients: scripts/new-client.sh <slug>"
echo "  7. Create projects: scripts/new-project.sh <client> <project>"
echo ""
echo "Docs: README.md"
