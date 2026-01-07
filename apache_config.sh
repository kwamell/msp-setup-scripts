#!/bin/bash
# =========================================
# FINAL EspoCRM Apache Fix (Guaranteed)
# =========================================

set -e

ESPODIR="/var/www/html/espo"
APACHE_SITE="/etc/apache2/sites-available/espo.conf"

echo "🔧 Enabling required Apache modules..."
sudo a2enmod rewrite headers env dir mime setenvif

echo "🛑 Disabling default Apache site..."
sudo a2dissite 000-default.conf || true

echo "📝 Writing EspoCRM Apache VirtualHost..."
sudo tee $APACHE_SITE > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName ktech-psa-db
    ServerAdmin admin@localhost

    DocumentRoot /var/www/html/espo/public

    Alias /client/ /var/www/html/espo/client/

    <Directory /var/www/html/espo>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/espo/public>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/espo/client>
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/espo_error.log
    CustomLog ${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOF

echo "✅ Enabling EspoCRM site..."
sudo a2ensite espo.conf

echo "🔐 Fixing ownership..."
sudo chown -R www-data:www-data $ESPODIR
sudo chmod -R 755 $ESPODIR

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ Apache is NOW correctly configured"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
