# nginx-php

![Docker Image CI](https://github.com/surreymagpie/nginx-php/actions/workflows/docker-image.yml/badge.svg)

A lightweight container image (~ 180MB) based on Alpine Linux and providing the nginx webserver with a php-fpm backend, and including PHP extensions commonly required by Drupal and Wordpress sites.

If the web root resides in a subdirectory of your project (e.g. drupal 8/9/10 projects using the `web` directory), pass the path through the `WEBROOT` environment variable as shown in the example below.

The container image has been tested using `podman` but should work just as well with `docker`.

### Basic usage

```bash
podman pull ghcr.io/surreymagpie/nginx-php:latest

podman run \
    --detach \
    --publish 8080:80 \
    --volume $(pwd):/var/www/html:Z \
  # --env=WEBROOT=my_subdir \
    --name my-container \
    ghcr.io/surreymagpie/nginx-php:latest

```
Visiting [localhost:8080](http://localhost:8080) will display a `phpinfo()` screen.

## Creating a new Drupal project

- Run the following command to create a new Drupal 10 project in a `MY-NEW-PROJECT` directory.

```bash
    # Using a disposable container to create the project
    podman run -it --rm \
    -v .:/var/www/html:Z \
    ghcr.io/surreymagpie/nginx-php \
    /bin/bash -c 'composer create-project drupal/recommended-project MY-NEW-PROJECT'
```
- Enter the project directory `cd MY-NEW-PROJECT`

- Copy the `compose.yml` file from this repo into that directory and edit if required.

- Start your containers with `podman compose up -d`

- **Recommended:**
    add `drush` to you project with
    `podman exec -it drupal10 composer require drush/drush`

- Visit [localhost:8080](http://localhost:8080) in your browser to install,
or use `podman exec -it drupal10 vendor/bin/drush site:install`.
The database credentials are all `drupal10` and the hostname is `db`.

## Aliases

The following aliases are very useful for interacting with the project as if they were natively on your host machine, rather than using lengthy `podman exec` commands.

```
alias composer='podman exec -it drupal10 composer'
alias drush='podman exec -it drupal10 vendor/bin/drush'
```
