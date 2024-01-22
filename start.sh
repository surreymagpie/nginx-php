#!/bin/bash

# Start php-fpm as root
/usr/sbin/php-fpm82 -R

# If WEBROOT variable is unset or empty, set the default root directory.
# Otherwise append the subdirectory path to the default.
if [[ ! -v WEBROOT ]] || [[ -z "$WEBROOT" ]]; then
    export WEBROOT=/var/www/html
else
    export WEBROOT=/var/www/html/$WEBROOT
fi

# Use environment substitution to change the configuration file
envsubst '$WEBROOT' < /etc/nginx/http.d/default.template > \
    /etc/nginx/http.d/default.conf

# Start nginx
/usr/sbin/nginx -g 'daemon off;'

