#!/bin/bash
# Create a new client folder structure
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <client_slug>"
  echo "Example: $0 smith_weddings"
  exit 1
fi

CLIENT="$1"
BASE="/mediapool/clients/client_${CLIENT}"

echo "=== Creating client: $CLIENT ==="

mkdir -p "$BASE/_meta/branding"
mkdir -p "$BASE/projects"
mkdir -p "$BASE/archive"

cat > "$BASE/_meta/client.json" <<EOF
{
  "name": "${CLIENT}",
  "email": "",
  "phone": "",
  "notes": "",
  "created": "$(date +%Y-%m-%d)"
}
EOF

touch "$BASE/_meta/branding/accent_color.txt"

cat > "$BASE/tvshow.nfo" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<tvshow>
  <title>${CLIENT} — Portfolio</title>
  <plot>Private portfolio collection for ${CLIENT}.</plot>
  <studio>Your Studio Name</studio>
  <lockdata>true</lockdata>
</tvshow>
EOF

sudo chown -R mediaserver:mediaserver "$BASE"
sudo chmod -R 755 "$BASE"

echo ""
echo "✓ Client directory created: $BASE"
echo ""
echo "Next: Create a Jellyfin library pointing to $BASE"
echo "      and create a Jellyfin user 'client_${CLIENT}'"
