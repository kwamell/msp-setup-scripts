#!/bin/bash
# =========================================
# FINAL 403 FORBIDDEN FIX FOR ESPOCRM
# =========================================

set -e

ESPODIR="/var/www/html/espo"
APACHE_SITE="/etc/apache2/sites-available/espo.conf"

echo "🔧 Enabling required Apache modules..."
sudo a2enmod rewrite php8.1 dir mime env headers

echo "🛑 Disabling all other Apache sites..."
sudo a2dissite 000-default.conf || true

echo "📝 Writing clean EspoCRM Apache config..."
sudo tee $APACHE_SITE > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName ktech-psa-db
    ServerAdmin admin@localhost

    DocumentRoot /var/www/html/espo/public

    DirectoryIndex index.php index.html

    Alias /client/ /var/www/html/espo/client/

    <Directory /var/www/html/espo/public>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/espo/client>
        Options FollowSymLinks
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/espo_error.log
    CustomLog ${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOF

echo "✅ Enabling EspoCRM site..."
sudo a2ensite espo.conf

echo "🔐 Fixing permissions (SAFE)..."
sudo chown -R www-data:www-data $ESPODIR
sudo find $ESPODIR -type d -exec chmod 755 {} \;
sudo find $ESPODIR -type f -exec chmod 644 {} \;

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ 403 Forbidden FIXED"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
