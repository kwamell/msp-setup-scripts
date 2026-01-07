#!/bin/bash
# =====================================
# PSA + PostgreSQL + Apache Setup Script
# For Ubuntu 24.04 LTS
# =====================================

# --- 1. Update system ---
sudo apt update && sudo apt upgrade -y

# --- 2. Install LAMP stack ---
sudo apt install apache2 php libapache2-mod-php php-pgsql php-mbstring php-xml php-curl unzip wget -y

# --- 3. Install PostgreSQL ---
sudo apt install postgresql postgresql-contrib -y

# --- 4. Configure PostgreSQL ---
# NOTE: Change 'StrongPassword123' to a secure password
DB_USER="psa_user"
DB_PASS="StrongPassword123"
DB_NAME="psa_db"

sudo -i -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\q
EOF

# --- 5. Download and install EspoCRM ---
wget https://www.espocrm.com/downloads/EspoCRM-7.1.10.zip -O EspoCRM.zip
unzip EspoCRM.zip -d /var/www/html/espo
sudo chown -R www-data:www-data /var/www/html/espo
sudo chmod -R 755 /var/www/html/espo

# --- 6. Configure Apache ---
cat <<EOL | sudo tee /etc/apache2/sites-available/espo.conf
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html/espo
    # NOTE: Change ServerName if you want a custom domain
    ServerName ktech-psa-db.local
    <Directory /var/www/html/espo/>
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

echo "✅ EspoCRM setup complete!"
echo "Open your browser: http://$(hostname -I | awk '{print $1}')/espo to finish the web installer."

