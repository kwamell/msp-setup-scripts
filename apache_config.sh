#!/bin/bash
# =========================================
# Fix EspoCRM Directory Structure
# =========================================

set -e

ESPODIR="/var/www/html/espo"
INNERDIR="$ESPODIR/EspoCRM-7.1.10"

echo "📁 Checking EspoCRM directory structure..."

if [ ! -d "$INNERDIR" ]; then
    echo "❌ Expected directory not found: $INNERDIR"
    exit 1
fi

echo "📦 Moving EspoCRM files up one level..."
sudo rsync -a $INNERDIR/ $ESPODIR/

echo "🧹 Removing extra EspoCRM directory..."
sudo rm -rf $INNERDIR

echo "🔐 Fixing ownership..."
sudo chown -R www-data:www-data $ESPODIR
sudo chmod -R 755 $ESPODIR

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ EspoCRM directory structure fixed"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
