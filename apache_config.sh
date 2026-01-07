#!/bin/bash
# =========================================
# Install EspoCRM required PHP extensions
# Works even when php8.3-* packages don't exist
# =========================================

set -e

echo "✅ Updating apt..."
sudo apt update

echo "✅ Installing PHP extensions EspoCRM needs..."
sudo apt install -y \
  php \
  php-cli \
  php-common \
  php-pgsql \
  php-zip \
  php-gd \
  php-mbstring \
  php-curl \
  php-xml \
  php-mysql

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "🧪 Verifying PHP modules are loaded..."
php -m | grep -E 'pdo_pgsql|pgsql|pdo_mysql|mysqli|zip|gd|mbstring|curl|xml' || true

echo "======================================"
echo "✅ Done. Refresh the EspoCRM installer."
echo "IMPORTANT:"
echo "- In the installer, change Database Type to PostgreSQL."
echo "- pdo_mysql will stop being required once PostgreSQL is selected."
echo "======================================"
