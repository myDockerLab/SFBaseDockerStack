#!/usr/bin/env bash

usermod -u `stat -c %u /var/www/app` www-data
groupmod -o -g `stat -c %g /var/www/app` www-data

# Execute all commands with user www-data
if [ "$1" = "apache2-foreground" ]; then
    exec "$@"
else
    exec /usr/local/bin/gosu www-data "$@"
fi
