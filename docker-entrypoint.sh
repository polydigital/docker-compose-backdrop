#!/bin/bash

cp /var/www/html/files-core/.htaccess /var/www/html/files/
chown -R www-data:www-data /var/www/html/files/
chmod -R 770 /var/www/html/files/
apache2-foreground
