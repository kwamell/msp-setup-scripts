#!/bin/bash
# =========================================
# Fix Apache MPM for PHP (REQUIRED)
# =========================================

set -e

echo "🛑 Disabling mpm_event..."
sudo a2dismod mpm_event || true

echo "✅ Enabling mpm_prefork..."
sudo a2enmod mpm_prefork

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ Apache MPM fixed for PHP"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
