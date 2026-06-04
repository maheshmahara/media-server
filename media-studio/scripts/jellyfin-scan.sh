#!/bin/bash
# Trigger Jellyfin library scan via API
set -euo pipefail

JELLYFIN_URL="http://localhost:8096"
API_KEY="${JELLYFIN_API_KEY:-}"   # Set in env or pass as arg

if [[ -z "$API_KEY" ]]; then
  echo "ERROR: Set JELLYFIN_API_KEY environment variable"
  echo "  Get it from Jellyfin: Dashboard → API Keys → Add"
  exit 1
fi

echo "=== Triggering Jellyfin library scan ==="
curl -s -X POST \
  "${JELLYFIN_URL}/Library/Refresh" \
  -H "X-Emby-Token: ${API_KEY}" \
  -H "Content-Type: application/json"

echo "✓ Scan triggered."
