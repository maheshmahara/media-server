#!/bin/bash
# Phase 3: Intel QSV / VAAPI Setup
set -euo pipefail

echo "=== Installing Intel Media Drivers ==="
sudo apt install -y intel-media-va-driver-non-free intel-opencl-icd \
  vainfo libva-utils i965-va-driver-shaders

echo ""
echo "=== GPU Devices ==="
ls -la /dev/dri/

echo ""
echo "=== VAAPI Capabilities ==="
vainfo --display drm --device /dev/dri/renderD128 2>&1 || vainfo

echo ""
echo "=== Creating mediaserver service user ==="
sudo useradd -r -s /bin/false mediaserver 2>/dev/null || echo "User already exists."
sudo usermod -aG render,video mediaserver

echo ""
echo "=== User info ==="
id mediaserver
echo ""
echo "=== Render group GID (use in Docker group_add) ==="
getent group render

echo ""
echo "✓ QSV setup complete."
echo "  Add the render GID shown above to RENDER_GID in your .env file."
