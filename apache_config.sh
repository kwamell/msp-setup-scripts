# Remove the bad "real file"
sudo rm -f /etc/apache2/mods-enabled/dir.conf

# Re-enable the module properly (creates correct symlinks)
sudo a2enmod dir

# Restart Apache
sudo systemctl restart apache2
