#!/bin/bash
# =========================================
# Finalize EspoCRM Setup (Post-Install)
# =========================================

set -e

ESPODIR="/var/www/html/espo"
PUBLICDIR="$ESPODIR/public"
CRONFILE="/etc/cron.d/espocrm"

echo "🔍 Verifying EspoCRM directories..."
if [ ! -f "$PUBLICDIR/index.php" ]; then
  echo "❌ EspoCRM public/index.php not found"
  exit 1
fi

echo "✅ Fixing ownership..."
sudo chown -R www-data:www-data "$ESPODIR"

echo "🔐 Fixing permissions (safe defaults)..."
sudo find "$ESPODIR" -type d -exec chmod 755 {} \;
sudo find "$ESPODIR" -type f -exec chmod 644 {} \;

echo "🧹 Removing leftover test/debug files..."
sudo rm -f "$PUBLICDIR/phpinfo.php" || true
sudo rm -f "$PUBLICDIR/healthz.html" || true

echo "⏱️ Installing EspoCRM cron job..."
sudo tee "$CRONFILE" > /dev/null <<EOF
* * * * * www-data /usr/bin/php $ESPODIR/cron.php > /dev/null 2>&1
EOF

sudo chmod 644 "$CRONFILE"
sudo systemctl restart cron

echo "🧪 Verifying cron installation..."
crontab -u www-data -l 2>/dev/null | grep cron.php || true

echo "🧪 Verifying PHP..."
php -v

echo "🔄 Restarting Apache (clean state)..."
sudo systemctl restart apache2

echo "======================================"
echo "✅ EspoCRM FINALIZED"
echo "🌐 URL: http://$(hostname -I | awk '{print $1}')/"
echo ""
echo "NEXT STEPS IN BROWSER:"
echo "  1) Complete EspoCRM installer (if not done)"
echo "  2) Admin → Administration → Scheduled Jobs"
echo "     (should show jobs running every minute)"
echo "======================================"
