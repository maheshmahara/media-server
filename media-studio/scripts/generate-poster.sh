#!/bin/bash
# Generate poster.jpg and fanart.jpg from a video file
set -euo pipefail

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
  echo "Usage: $0 <video_file> <output_dir>"
  echo "Example: $0 /mediapool/clients/smith/projects/wedding/delivery/smith_1080p.mp4 /mediapool/clients/smith/projects/wedding/meta"
  exit 1
fi

VIDEO="$1"
OUTDIR="$2"
mkdir -p "$OUTDIR"

# Poster — 2:3 ratio, 600x900, from 10% mark
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$VIDEO")
POSTER_TS=$(echo "$DURATION * 0.10" | bc)
FANART_TS=$(echo "$DURATION * 0.25" | bc)

echo "Generating poster.jpg (${POSTER_TS}s)..."
ffmpeg -ss "$POSTER_TS" -i "$VIDEO" \
  -vframes 1 \
  -vf "scale=600:900:force_original_aspect_ratio=increase,crop=600:900" \
  -q:v 2 "$OUTDIR/poster.jpg" -y

echo "Generating fanart.jpg (${FANART_TS}s)..."
ffmpeg -ss "$FANART_TS" -i "$VIDEO" \
  -vframes 1 \
  -vf "scale=1920:1080" \
  -q:v 2 "$OUTDIR/fanart.jpg" -y

echo "Generating folder.jpg (square copy of poster)..."
ffmpeg -i "$OUTDIR/poster.jpg" \
  -vf "crop='min(iw,ih)':'min(iw,ih)',scale=600:600" \
  -q:v 2 "$OUTDIR/folder.jpg" -y

echo ""
echo "✓ Art files written to $OUTDIR"
ls -lh "$OUTDIR"/*.jpg
