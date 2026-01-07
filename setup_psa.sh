#!/bin/bash
# =========================================
# Fully automated EspoCRM PSA setup
# Hostname: ktech-psa-db
# Apache, PHP, PostgreSQL
# =========================================

# -----------------------------
# Variables (change as needed)
# -----------------------------
DB_USER="psa_user"
DB_PASS="StrongPassword123"
DB_NAME="psa_db"
ADMIN_USER="admin"
ADMIN_PASS="Admin123!"
ESPODIR="/var/www/html/espo"

# -----------------------------
# 1. Update system and install packages
# -----------------------------
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common wget unzip apache2 php libapache2-mod-php php-pgsql php-mbstring php-xml php-curl postgresql postgresql-contrib
sudo add-apt-repository universe -y
sudo apt update

# -----------------------------
# 2. Start and enable services
# -----------------------------
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable postgresql
sudo systemctl start postgresql

# -----------------------------
# 3. Create PostgreSQL user/database
# -----------------------------
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
# 4. Download and unzip EspoCRM
# -----------------------------
sudo rm -rf $ESPODIR
sudo mkdir -p $ESPODIR
sudo wget -O EspoCRM.zip https://www.espocrm.com/downloads/EspoCRM-7.1.10.zip
sudo unzip -o EspoCRM.zip -d /var/www/html/espo

# Fix folder structure (move contents from EspoCRM-7.1.10/* to /espo)
sudo mv $ESPODIR/EspoCRM-7.1.10/* $ESPODIR/
sudo rm -rf $ESPODIR/EspoCRM-7.1.10

# -----------------------------
# 5. Set permissions
# -----------------------------
sudo chown -R www-data:www-data $ESPODIR
sudo chmod -R 755 $ESPODIR

# -----------------------------
# 6. Configure Apache site
# -----------------------------
cat <<EOL | sudo tee /etc/apache2/sites-available/espo.conf
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot $ESPODIR
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
# 7. Configure EspoCRM automatically
# -----------------------------
CONFIG_FILE="$ESPODIR/data/config.php"

cat <<EOL | sudo tee $CONFIG_FILE
<?php
return array(
    'siteUrl' => 'http://$(hostname -I | awk '{print $1}')/espo',
    'dbType' => 'pgsql',
    'dbHost' => '127.0.0.1',
    'dbPort' => 5432,
    'dbName' => '$DB_NAME',
    'dbUser' => '$DB_USER',
    'dbPassword' => '$DB_PASS',
    'siteName' => 'KTECH PSA',
    'defaultLanguage' => 'en_US',
    'defaultTimezone' => 'America/New_York',
    'defaultAdminUserName' => '$ADMIN_USER',
    'defaultAdminPassword' => '$ADMIN_PASS'
);
?>
EOL

sudo chown www-data:www-data $CONFIG_FILE
sudo chmod 640 $CONFIG_FILE

# -----------------------------
# 8. Firewall
# -----------------------------
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload || true

# -----------------------------
# 9. Finish
# -----------------------------
echo "======================================"
echo "✅ EspoCRM PSA fully installed!"
echo "Database: $DB_NAME"
echo "DB User: $DB_USER"
echo "DB Pass: $DB_PASS"
echo "Admin User: $ADMIN_USER"
echo "Admin Pass: $ADMIN_PASS"
echo "Web URL: http://$(hostname -I | awk '{print $1}')/espo"
echo "Open your browser and log in with the admin credentials above."
echo "======================================"
