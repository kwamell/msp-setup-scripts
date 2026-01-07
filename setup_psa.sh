sudo apt update && sudo apt upgrade -y && \
sudo apt install -y software-properties-common wget unzip apache2 php libapache2-mod-php php-pgsql php-mbstring php-xml php-curl postgresql postgresql-contrib && \
sudo add-apt-repository universe -y && sudo apt update && \
# Create database and user
DB_USER="psa_user" && DB_PASS="StrongPassword123" && DB_NAME="psa_db" && \
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
# Download and unzip EspoCRM
ESPODIR="/var/www/html/espo" && \
sudo rm -rf $ESPODIR && \
sudo wget -O EspoCRM.zip https://www.espocrm.com/downloads/EspoCRM-7.1.10.zip && \
sudo unzip -o EspoCRM.zip -d $ESPODIR && \
sudo chown -R www-data:www-data $ESPODIR && sudo chmod -R 755 $ESPODIR && \
# Apache site config
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
# Enable site and modules
sudo a2ensite espo.conf && sudo a2enmod rewrite && sudo systemctl restart apache2 && \
# Firewall
sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw reload || true && \
# Final message
echo "======================================" && \
echo "✅ EspoCRM PSA setup complete!" && \
echo "Database: $DB_NAME" && echo "DB User: $DB_USER" && echo "DB Pass: $DB_PASS" && \
echo "Web URL: http://$(hostname -I | awk '{print $1}')/espo" && \
echo "Open your browser to finish the web installer." && \
echo "======================================"
