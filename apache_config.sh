echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/espo/public/phpinfo.php > /dev/null
sudo chown www-data:www-data /var/www/html/espo/public/phpinfo.php
