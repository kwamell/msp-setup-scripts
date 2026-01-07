#!/bin/bash
# =========================================
# Install required PHP extensions for EspoCRM
# Ubuntu + Apache + PHP 8.3
# =========================================

set -e

echo "✅ Installing required PHP extensions..."

sudo apt update

sudo apt install -y \
  php8.3-pgsql \
  php8.3-zip \
  php8.3-gd \
  php8.3-mbstring \
  php8.3-curl \
  php8.3-xml

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "🧪 Verifying loaded PHP modules..."
php -m | grep -E 'pgsql|zip|gd|mbstring|curl|xml' || true

echo "======================================"
echo "✅ PHP extensions installed"
echo "👉 Refresh the EspoCRM installer page"
echo "======================================"
