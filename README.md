# nginx-php

![Docker Image CI](https://github.com/surreymagpie/nginx-php/actions/workflows/docker-image.yml/badge.svg)

A lightweight container image (~ 180MB) based on Alpine Linux and providing the
nginx webserver with a php-fpm backend, and including PHP extensions commonly
required by Drupal and Wordpress sites.

If the web root resides in a subdirectory of your project (e.g. drupal 8/9/10
projects using the `web` directory), pass the path through the `WEBROOT`
environment variable as shown in the example below.

The container image has been tested using `Podman` but should work just as well
with `Docker`.

```bash
podman pull ghcr.io/surreymagpie/nginx-php:latest

podman run \
    --detach \
    --publish 8080:80 \
    --volume $(pwd):/var/www/html:Z \
    --env=WEBROOT=my_subdir \
    --name my-container \
    ghcr.io/surreymagpie/nginx-php:latest
```

