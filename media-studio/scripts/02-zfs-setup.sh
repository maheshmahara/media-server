#!/bin/bash
# Phase 2: ZFS Storage Setup
set -euo pipefail

echo "=== Installing ZFS ==="
sudo apt install -y zfsutils-linux

echo ""
echo "=== Available drives (use these IDs in the pool command below) ==="
ls -la /dev/disk/by-id/ | grep -v part | grep -v lvm | grep ata

echo ""
echo "=== MANUAL STEP REQUIRED ==="
echo "Edit the zpool create command below with your actual drive IDs, then run it."
echo ""
cat <<'ZPOOL_CMD'
# Adjust drive count and IDs to your hardware
# Example: 6x drives = RAIDZ2 → ~4x capacity usable
sudo zpool create -o ashift=12 \
  -O compression=lz4 \
  -O atime=off \
  -O recordsize=1M \
  -O xattr=sa \
  mediapool raidz2 \
  /dev/disk/by-id/ata-YOUR_DRIVE_1 \
  /dev/disk/by-id/ata-YOUR_DRIVE_2 \
  /dev/disk/by-id/ata-YOUR_DRIVE_3 \
  /dev/disk/by-id/ata-YOUR_DRIVE_4 \
  /dev/disk/by-id/ata-YOUR_DRIVE_5 \
  /dev/disk/by-id/ata-YOUR_DRIVE_6
ZPOOL_CMD

echo ""
read -p "Have you edited and run the zpool create command? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Run this script again after creating the pool."
  exit 1
fi

echo "=== Creating ZFS Datasets ==="
sudo zfs create mediapool/clients
sudo zfs create mediapool/staging
sudo zfs create mediapool/cache
sudo zfs create mediapool/transcode_tmp

echo "=== Installing Sanoid for automated snapshots ==="
sudo apt install -y sanoid

sudo tee /etc/sanoid/sanoid.conf > /dev/null <<'EOF'
[mediapool/clients]
    use_template = production
    recursive = yes

[template_production]
    frequently = 0
    hourly = 0
    daily = 30
    weekly = 12
    monthly = 6
    autosnap = yes
    autoprune = yes
EOF

sudo systemctl enable --now sanoid.timer

echo "=== Setting up monthly ZFS scrub ==="
(crontab -l 2>/dev/null; echo "0 2 1 * * /usr/sbin/zpool scrub mediapool") | crontab -

echo ""
echo "✓ ZFS setup complete."
zpool status
zfs list
