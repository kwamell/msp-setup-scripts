#!/bin/bash
# =========================================
# Repair Apache dir module (symlink fix)
# =========================================

set -e

echo "🔍 Checking dir.conf status..."

if [ -f /etc/apache2/mods-enabled/dir.conf ] && [ ! -L /etc/apache2/mods-enabled/dir.conf ]; then
    echo "⚠️ dir.conf is a real file — removing it"
    sudo rm -f /etc/apache2/mods-enabled/dir.conf
fi

echo "✅ Enabling dir module properly..."
sudo a2enmod dir

echo "🔧 Ensuring PHP module is enabled..."
sudo a2enmod php*

echo "🔧 Ensuring correct MPM for mod_php..."
sudo a2dismod mpm_event || true
sudo a2enmod mpm_prefork

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "🧪 Testing Apache configuration..."
sudo apachectl -t

echo "======================================"
echo "✅ Apache module system repaired"
echo "🌐 Test: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
