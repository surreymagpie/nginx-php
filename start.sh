#!/bin/sh

#Start php-fpm
/usr/sbin/php-fpm82 

# Start nginx
/usr/sbin/nginx -g 'daemon off;'

# enable SSH
eval $(ssh-agent)
