#!/bin/bash
set -e

ESPODIR="/var/www/html/espo"

echo "== Updating packages =="
sudo apt update -y

echo "== Installing PHP drivers Espo uses (unversioned packages) =="
sudo apt install -y \
  php-pgsql \
  php-mysql \
  php-zip \
  php-gd \
  php-mbstring \
  php-curl \
  php-xml

echo "== Restarting Apache =="
sudo systemctl restart apache2

echo "== Verifying PHP modules (must show pdo_pgsql) =="
php -m | grep -E 'pdo_pgsql|pgsql' || true
php -m | grep -E 'pdo_mysql|mysqli' || true
php -m | grep -E 'zip|gd|mbstring|curl|xml' || true

echo "== Checking PostgreSQL service =="
sudo systemctl is-active --quiet postgresql && echo "PostgreSQL is running ✅" || echo "PostgreSQL is NOT running ❌"

echo "== Resetting Espo installer state (so DB options re-detect) =="
# These files get created during a partially completed install
sudo rm -f "$ESPODIR/data/config.php" "$ESPODIR/data/config-internal.php" || true
sudo rm -rf "$ESPODIR/data/cache/*" || true

sudo chown -R www-data:www-data "$ESPODIR"

echo "== Done =="
echo "Now HARD refresh the installer page (Ctrl+F5) and check Database Type again."
echo "If PostgreSQL still doesn't appear, run: psql --version and tell me the result."
