#!/bin/bash
# Nightly backup to Backblaze B2
set -euo pipefail

source /opt/docker/.env

DATE=$(date +%Y%m%d)
LOGFILE=/var/log/media-backup-${DATE}.log

echo "$(date): Starting backup" >> "$LOGFILE"

# Sync delivery files (exclude raw footage — too large)
rclone sync "$MEDIA_ROOT" \
  "b2:${B2_BUCKET}/clients" \
  --transfers 4 \
  --b2-chunk-size 100M \
  --log-file "$LOGFILE" \
  --log-level INFO \
  --exclude "raw/**" \
  --exclude "*.MOV" \
  --exclude "transcode_tmp/**"

# Backup Docker configs (no secrets — .env is excluded)
rclone sync /opt/docker "b2:${B2_BUCKET}/docker-config" \
  --log-file "$LOGFILE" \
  --exclude ".env"

echo "$(date): Backup complete" >> "$LOGFILE"
