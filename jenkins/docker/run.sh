#!/bin/sh

php /var/www/html/artisan l5-swagger:generate

php artisan cache:clear
php artisan route:cache

/usr/bin/supervisord -c /etc/supervisord.conf

