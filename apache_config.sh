#!/bin/bash
# =========================================
# Force EspoCRM Apache vhost (fix persistent 403)
# =========================================
set -e

ESPODIR="/var/www/html/espo"
PUBLICDIR="/var/www/html/espo/public"
CLIENTDIR="/var/www/html/espo/client"

echo "✅ Checking required files..."
if [ ! -f "$PUBLICDIR/index.php" ]; then
  echo "❌ Missing: $PUBLICDIR/index.php"
  echo "Your EspoCRM files are not in the expected location."
  exit 1
fi

echo "🔧 Enabling required modules..."
sudo a2enmod rewrite dir php8.3 >/dev/null || true
sudo a2dismod mpm_event >/dev/null || true
sudo a2enmod mpm_prefork >/dev/null || true

echo "🛑 Disabling default site (prevents override)..."
sudo a2dissite 000-default.conf >/dev/null || true

echo "📝 Writing EspoCRM vhost..."
sudo tee /etc/apache2/sites-available/espo.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName ktech-psa-db
    ServerAdmin admin@localhost

    DocumentRoot "$PUBLICDIR"
    DirectoryIndex index.php index.html

    Alias /client/ "$CLIENTDIR/"

    <Directory "$PUBLICDIR">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory "$CLIENTDIR">
        Options FollowSymLinks
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/espo_error.log
    CustomLog \${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOF

echo "✅ Enabling EspoCRM site..."
sudo a2ensite espo.conf >/dev/null || true

echo "🔐 Fixing ownership + traversal permissions..."
sudo chown -R www-data:www-data "$ESPODIR"
sudo chmod 755 /var /var/www /var/www/html "$ESPODIR" "$PUBLICDIR" "$CLIENTDIR" || true

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "🧪 Quick local test (should NOT be 403)..."
curl -I http://localhost/ | head -n 1 || true

echo "======================================"
echo "✅ Forced EspoCRM vhost applied"
echo "🌐 Open: http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
