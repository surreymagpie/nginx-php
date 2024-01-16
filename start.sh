#!/bin/sh

#Start php-fpm as root
/usr/sbin/php-fpm82 -R

# Start nginx
/usr/sbin/nginx -g 'daemon off;'

# enable SSH
eval $(ssh-agent)
