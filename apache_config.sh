#!/bin/bash
set -e

echo "=== Locating EspoCRM public/index.php ==="
INDEX_PATH="$(sudo find /var/www/html/espo -type f -path "*/public/index.php" 2>/dev/null | head -n 1)"

if [ -z "$INDEX_PATH" ]; then
  echo "❌ Could not find EspoCRM public/index.php under /var/www/html/espo"
  exit 1
fi

PUBLIC_DIR="$(dirname "$INDEX_PATH")"
ESPO_DIR="$(dirname "$PUBLIC_DIR")"
CLIENT_DIR="$ESPO_DIR/client"

echo "✅ Found:"
echo "PUBLIC_DIR=$PUBLIC_DIR"
echo "ESPO_DIR=$ESPO_DIR"
echo "CLIENT_DIR=$CLIENT_DIR"

echo "=== Forcing Apache modules ==="
sudo a2enmod rewrite dir >/dev/null || true
sudo a2dismod mpm_event >/dev/null || true
sudo a2enmod mpm_prefork >/dev/null || true
sudo a2enmod php8.3 >/dev/null || sudo a2enmod php* >/dev/null || true

echo "=== Disabling default site to avoid conflicts ==="
sudo a2dissite 000-default.conf >/dev/null || true

echo "=== Writing Espo vhost ==="
sudo tee /etc/apache2/sites-available/espo.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName ktech-psa-db
    ServerAdmin admin@localhost

    DocumentRoot "$PUBLIC_DIR"
    DirectoryIndex index.php index.html

    Alias /client/ "$CLIENT_DIR/"

    <Directory "$PUBLIC_DIR">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory "$CLIENT_DIR">
        Options FollowSymLinks
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/espo_error.log
    CustomLog \${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOF

echo "=== Enabling espo site ==="
sudo a2ensite espo.conf >/dev/null || true

echo "=== Creating a hard healthcheck file in DocumentRoot ==="
echo "OK $(date)" | sudo tee "$PUBLIC_DIR/healthz.html" >/dev/null

echo "=== Fixing ownership ==="
sudo chown -R www-data:www-data "$ESPO_DIR"

echo "=== Restarting Apache ==="
sudo systemctl restart apache2

echo "=== Local verification ==="
echo "curl -I http://localhost/healthz.html"
curl -I http://localhost/healthz.html | head -n 5 || true
echo
echo "curl -I http://localhost/"
curl -I http://localhost/ | head -n 5 || true

echo "======================================"
echo "✅ Done."
echo "Test in browser:"
echo "  http://$(hostname -I | awk '{print $1}')/healthz.html"
echo "  http://$(hostname -I | awk '{print $1}')/"
echo "======================================"
