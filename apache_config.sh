#!/bin/bash
# =========================================
# Fix EspoCRM Apache Configuration (FAST)
# =========================================

set -e

ESPODIR="/var/www/html/espo"
APACHE_SITE="/etc/apache2/sites-available/espo.conf"

echo "🔧 Enabling Apache rewrite module..."
sudo a2enmod rewrite

echo "📝 Writing Apache VirtualHost configuration..."
sudo tee $APACHE_SITE > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerAdmin admin@localhost
    ServerName ktech-psa-db

    DocumentRoot /var/www/html/espo/public
    Alias /client/ /var/www/html/espo/client/

    <Directory /var/www/html/espo/public/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/espo/client/>
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/espo_error.log
    CustomLog ${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOF

echo "✅ Enabling site..."
sudo a2ensite espo.conf

echo "🔐 Fixing ownership (no recursive chmod)..."
sudo chown -R www-data:www-data $ESPODIR
sudo chmod 755 $ESPODIR
sudo chmod 755 $ESPODIR/public
sudo chmod 755 $ESPODIR/client

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ EspoCRM Apache configuration fixed"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
