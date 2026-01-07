#!/bin/bash
# =========================================
# Complete PSA Setup Script (EspoCRM)
# Ubuntu 24.04 / ESXi VM
# Hostname: ktech-psa-db
# Includes:
# - Apache2 + PHP modules
# - PostgreSQL database
# - EspoCRM installation
# - Permissions and Apache config
# =========================================

# -----------------------------
# 1. Update system
# -----------------------------
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# -----------------------------
# 2. Install Apache2 and PHP modules
# -----------------------------
echo "Installing Apache2 and PHP modules..."
sudo apt install -y apache2 php libapache2-mod-php php-pgsql php-mbstring php-xml php-curl unzip wget

# -----------------------------
# 3. Enable and start Apache2
# -----------------------------
echo "Enabling and starting Apache..."
sudo systemctl enable apache2
sudo systemctl start apache2

# -----------------------------
# 4. Install PostgreSQL
# -----------------------------
echo "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# -----------------------------
# 5. Configure PostgreSQL
# -----------------------------
# NOTE: Change these values as needed
DB_USER="psa_user"
DB_PASS="StrongPassword123"
DB_NAME="psa_db"

echo "Configuring PostgreSQL database..."
sudo -i -u postgres psql <<EOF
DO
\$do\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
   END IF;
END
\$do\$;
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\q
EOF

# -----------------------------
# 6. Download and install EspoCRM
# -----------------------------
ESPODIR="/var/www/html/espo"
echo "Downloading EspoCRM..."
wget -O EspoCRM.zip https://www.espocrm.com/downloads/EspoCRM-7.1.10.zip
sudo unzip -o EspoCRM.zip -d $ESPODIR
sudo chown -R www-data:www-data $ESPODIR
sudo chmod -R 755 $ESPODIR

# -----------------------------
# 7. Configure Apache site for EspoCRM
# -----------------------------
echo "Configuring Apache site..."
cat <<EOL | sudo tee /etc/apache2/sites-available/espo.conf
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot $ESPODIR
    # Hostname set to your VM hostname
    ServerName ktech-psa-db
    <Directory $ESPODIR/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/espo_error.log
    CustomLog \${APACHE_LOG_DIR}/espo_access.log combined
</VirtualHost>
EOL

sudo a2ensite espo.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# -----------------------------
# 8. Firewall (UFW) adjustments
# -----------------------------
echo "Configuring firewall..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload || true

# -----------------------------
# 9. Final status
# -----------------------------
echo "======================================"
echo "✅ EspoCRM PSA setup complete!"
echo "Database: $DB_NAME"
echo "DB User: $DB_USER"
echo "DB Pass: $DB_PASS"
echo "Web URL: http://$(hostname -I | awk '{print $1}')/espo"
echo "Open your browser to finish the web installer."
echo "======================================"
