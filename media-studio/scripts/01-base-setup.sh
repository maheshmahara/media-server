#!/bin/bash
# Phase 1 & 2: Base OS + Docker setup
set -euo pipefail

echo "=== Phase 1: Base OS Setup ==="

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git htop ncdu tmux ufw fail2ban \
  build-essential linux-headers-$(uname -r) \
  unattended-upgrades

echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
sudo apt install -y docker-compose-plugin
echo "Docker installed. You may need to log out and back in for group changes."

echo "=== Configuring UFW Firewall ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp   # SSH custom port — change sshd_config first
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "=== Enabling Fail2Ban ==="
sudo systemctl enable --now fail2ban

echo "=== Enabling Auto Security Updates ==="
sudo dpkg-reconfigure --priority=low unattended-upgrades

echo "=== Disabling Unused Services ==="
sudo systemctl disable bluetooth 2>/dev/null || true
sudo systemctl disable avahi-daemon 2>/dev/null || true

echo ""
echo "✓ Phase 1 complete. Edit /etc/ssh/sshd_config next:"
echo "  PermitRootLogin no"
echo "  PasswordAuthentication no"
echo "  Port 2222"
echo "  AllowUsers \$YOUR_USERNAME"
