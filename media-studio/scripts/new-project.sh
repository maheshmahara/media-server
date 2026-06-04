#!/bin/bash
# Create a new project under a client
set -euo pipefail

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
  echo "Usage: $0 <client_slug> <project_slug>"
  echo "Example: $0 smith_weddings 2024_wedding_main"
  exit 1
fi

CLIENT="$1"
PROJECT="$2"
BASE="/mediapool/clients/client_${CLIENT}/projects/${PROJECT}"

echo "=== Creating project: $PROJECT for $CLIENT ==="

mkdir -p "$BASE/raw"
mkdir -p "$BASE/edit"
mkdir -p "$BASE/delivery"
mkdir -p "$BASE/photos/raw"
mkdir -p "$BASE/photos/gallery"
mkdir -p "$BASE/meta"

YEAR=$(echo "$PROJECT" | grep -oP '^\d{4}' || date +%Y)

cat > "$BASE/meta/movie.nfo" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
  <title>${PROJECT//_/ }</title>
  <originaltitle>${PROJECT//_/ }</originaltitle>
  <sorttitle>${PROJECT}</sorttitle>
  <year>${YEAR}</year>
  <plot>Project description goes here.</plot>
  <tagline></tagline>
  <runtime>0</runtime>
  <genre>Portfolio</genre>
  <tag>Private Delivery</tag>
  <tag>${YEAR}</tag>
  <studio>Your Studio Name</studio>
  <director>Your Name</director>
  <premiered>${YEAR}-01-01</premiered>
  <releasedate>${YEAR}-01-01</releasedate>
  <thumb aspect="poster">poster.jpg</thumb>
  <thumb aspect="banner">fanart.jpg</thumb>
  <fanart>
    <thumb>fanart.jpg</thumb>
  </fanart>
  <lockdata>true</lockdata>
</movie>
EOF

sudo chown -R mediaserver:mediaserver "$BASE"
sudo chmod -R 755 "$BASE"

echo ""
echo "✓ Project created: $BASE"
echo ""
echo "After dropping source files in $BASE/raw/, run:"
echo "  sudo chattr +i $BASE/raw/   (makes raw files immutable)"
