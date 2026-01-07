grep -n "DocumentRoot\|Alias /client\|AllowOverride" /etc/apache2/sites-enabled/espo.conf

echo "ServerName ktech-psa-db" | sudo tee /etc/apache2/conf-available/servername.conf > /dev/null
sudo a2enconf servername
sudo systemctl restart apache2
