#!/bin/bash
# Setup rclone + Backblaze B2 backup cron
set -euo pipefail

echo "=== Installing rclone ==="
curl https://rclone.org/install.sh | sudo bash

echo ""
echo "=== Configuring rclone for Backblaze B2 ==="
echo "Run: rclone config"
echo "  n → new remote"
echo "  name: b2"
echo "  type: 2 (Backblaze B2)"
echo "  Enter your B2 Account ID and Application Key"
echo ""
read -p "Have you configured rclone? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Run 'rclone config' first, then re-run this script."
  exit 1
fi

echo "=== Testing B2 connection ==="
source /opt/docker/.env
rclone ls "b2:${B2_BUCKET}" && echo "✓ B2 connection successful"

echo "=== Installing backup script ==="
sudo cp "$(dirname "$0")/backup-media.sh" /opt/scripts/backup-media.sh
sudo chmod +x /opt/scripts/backup-media.sh

echo "=== Adding nightly cron (3 AM) ==="
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/scripts/backup-media.sh >> /var/log/media-backup.log 2>&1") | crontab -

echo "✓ Backup configured. Test manually: /opt/scripts/backup-media.sh"
