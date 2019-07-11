#!/bin/bash

cp /var/www/html/files-core/.htaccess /var/www/html/files/
chown -R www-data:www-data /var/www/html/files/
chmod -R 770 /var/www/html/files/
chown -R www-data:www-data /var/www/html/modules/
chmod -R 770 /var/www/html/modules/
chown -R www-data:www-data /var/www/html/layouts/
chmod -R 770 /var/www/html/layouts/
chown -R www-data:www-data /var/www/html/themes/
chmod -R 770 /var/www/html/themes/

apache2-foreground
