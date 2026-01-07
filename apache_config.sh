sudo tee /etc/cron.d/espocrm > /dev/null <<'EOF'
* * * * * www-data /usr/bin/php /var/www/html/espo/cron.php > /dev/null 2>&1
EOF
sudo systemctl restart cron
sudo rm -f /var/www/html/espo/public/phpinfo.php
