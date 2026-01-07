# See installed PHP versions
php -v

# Enable PHP module explicitly
sudo a2enmod php*

# Ensure dir module is enabled
sudo a2enmod dir

# Force DirectoryIndex to include index.php globally
sudo sed -i 's/DirectoryIndex .*/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf

# Restart Apache
sudo systemctl restart apache2
