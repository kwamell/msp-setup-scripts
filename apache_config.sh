#!/bin/bash
# =========================================
# Tune PHP settings for EspoCRM on Apache
# Updates all loaded php.ini files for CLI + Apache
# =========================================

set -e

echo "🔎 Detecting PHP version..."
PHPV="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
echo "PHP version detected: $PHPV"

INI_FILES=(
  "/etc/php/$PHPV/apache2/php.ini"
  "/etc/php/$PHPV/cli/php.ini"
)

echo "🛠️ Applying EspoCRM recommended settings..."
for INI in "${INI_FILES[@]}"; do
  if [ -f "$INI" ]; then
    echo "Updating: $INI"
    sudo sed -i 's/^\s*max_execution_time\s*=.*/max_execution_time = 180/' "$INI"
    sudo sed -i 's/^\s*max_input_time\s*=.*/max_input_time = 180/' "$INI"
    sudo sed -i 's/^\s*memory_limit\s*=.*/memory_limit = 256M/' "$INI"
    sudo sed -i 's/^\s*post_max_size\s*=.*/post_max_size = 20M/' "$INI"
    sudo sed -i 's/^\s*upload_max_filesize\s*=.*/upload_max_filesize = 20M/' "$INI"
  else
    echo "Skipping (not found): $INI"
  fi
done

echo "🔄 Restarting Apache..."
sudo systemctl restart apache2

echo "✅ Done. Current PHP values (CLI):"
php -r '
echo "max_execution_time=".ini_get("max_execution_time").PHP_EOL;
echo "max_input_time=".ini_get("max_input_time").PHP_EOL;
echo "memory_limit=".ini_get("memory_limit").PHP_EOL;
echo "post_max_size=".ini_get("post_max_size").PHP_EOL;
echo "upload_max_filesize=".ini_get("upload_max_filesize").PHP_EOL;
'
echo "======================================"
echo "✅ Refresh the EspoCRM requirements page."
echo "======================================"
