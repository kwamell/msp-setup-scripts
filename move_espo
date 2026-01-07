# Move the files out of the nested folder
sudo mv /var/www/html/espo/EspoCRM-7.1.10/* /var/www/html/espo/
sudo mv /var/www/html/espo/EspoCRM-7.1.10/.* /var/www/html/espo/ 2>/dev/null || true  # move hidden files like .htaccess

# Remove the now-empty nested folder
sudo rm -rf /var/www/html/espo/EspoCRM-7.1.10

# Fix permissions
sudo chown -R www-data:www-data /var/www/html/espo
sudo chmod -R 755 /var/www/html/espo

# Restart Apache
sudo systemctl restart apache2
