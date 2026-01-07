#!/bin/bash
# =========================================
# Apache GLOBAL filesystem allow fix
# =========================================

set -e

APACHE_MAIN="/etc/apache2/apache2.conf"

echo "📝 Backing up apache2.conf..."
sudo cp $APACHE_MAIN ${APACHE_MAIN}.bak

echo "🔧 Appending global directory permissions..."

sudo tee -a $APACHE_MAIN > /dev/null <<'EOF'

# === EspoCRM Global Allow Fix ===
<Directory /var/www/>
    AllowOverride All
    Require all granted
</Directory>

<Directory /var/www/html/>
    AllowOverride All
    Require all granted
</Directory>
# === End Fix ===

EOF

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ Apache global access fixed"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
