#!/bin/bash
# =========================================
# Fix Apache Directory Traverse Permissions
# =========================================

set -e

echo "🔐 Fixing parent directory permissions..."

sudo chmod 755 /var
sudo chmod 755 /var/www
sudo chmod 755 /var/www/html
sudo chmod 755 /var/www/html/espo
sudo chmod 755 /var/www/html/espo/public
sudo chmod 755 /var/www/html/espo/client

echo "👤 Ensuring ownership..."
sudo chown -R www-data:www-data /var/www/html/espo

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ Directory traversal permissions fixed"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
