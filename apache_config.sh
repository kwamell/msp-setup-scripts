sudo a2enmod rewrite
sudo service apache2 restart

<Directory /var/www/html/espo>
  AllowOverride All
</Directory>

DocumentRoot /var/www/html/espo/public/
Alias /client/ /var/www/html/espo/client/

<Directory /var/www/html/espo/public/>
  AllowOverride All
</Directory>
