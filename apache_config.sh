#!/bin/bash
# =========================================
# Install MariaDB for EspoCRM (MySQL mode)
# Creates:
#   DB:   psa_db
#   User: psa_user
#   Pass: StrongPassword123 (change if you want)
# =========================================

set -e

DB_NAME="psa_db"
DB_USER="psa_user"
DB_PASS="StrongPassword123"

echo "✅ Installing MariaDB..."
sudo apt update
sudo apt install -y mariadb-server mariadb-client

echo "✅ Enabling and starting MariaDB..."
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo "✅ Setting MariaDB to listen on localhost only (safe default)..."
# Most installs already bind to 127.0.0.1. This keeps it local-only.
sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf || true

echo "✅ Restarting MariaDB..."
sudo systemctl restart mariadb

echo "✅ Creating database + user..."
sudo mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "🧪 Testing login as ${DB_USER}..."
mariadb -u "${DB_USER}" -p"${DB_PASS}" -e "SHOW DATABASES;" | head -n 20

echo "======================================"
echo "✅ MariaDB ready for EspoCRM installer"
echo ""
echo "In EspoCRM installer (MySQL):"
echo "  Host Name: 127.0.0.1   (DO NOT use :5432)"
echo "  Database Name: ${DB_NAME}"
echo "  Database User Name: ${DB_USER}"
echo "  Database User Password: ${DB_PASS}"
echo "======================================"
