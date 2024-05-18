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
Visiting [localhost:8080][def] will display a `phpinfo()` screen.

## Creating a new Drupal project

- Run the following commands to create a new Drupal 10 project in a `MY-NEW-PROJECT` directory.

```bash
# Using a disposable container to create the project
podman run -it --rm \
  -v .:/var/www/html:Z \
  ghcr.io/surreymagpie/nginx-php:latest \
  /bin/bash -c 'composer create-project drupal/recommended-project MY-NEW-PROJECT'

# Enter the project directory
cd MY-NEW-PROJECT

# Copy the `compose.yml` file from this repo into that directory and edit if required.
wget https://raw.githubusercontent.com/surreymagpie/nginx-php/main/drupal-compose.yml -O compose.yml

# Start your containers 
podman compose up -d`

# The following aliases are very useful for interacting with the project as if they
# were natively on your host machine, rather than using lengthy 'podman exec' commands.
alias composer='podman exec -it drupal10 composer'
alias drush='podman exec -it drupal10 drush'

# **Recommended:** add 'drush' to you project with:
composer require drush/drush

# Install the site
drush site:install standard \
  --locale=en-gb \
  --db-url=mysql://drupal10:drupal10@db:3306/drupal10
```
- The site is accessible at [localhost:8080][def]
- Email is intercepted locally by Mailhog and is accessed on [localhost:8025][def2]

## Starting a Wordpress project
In a similar fashion, a wordpress installation can be rapidly created.

````bash
# Download the code base
podman run -it --rm \
  -v .:/var/www/html:Z \
  ghcr.io/surreymagpie/nginx-php:latest \
  wp core download --allow-root --locale=en_GB --path=MY-WORDPRESS

cd MY-WORDPRESS

# Download the `wordpress-compose.yml` file
wget https://raw.githubusercontent.com/surreymagpie/nginx-php/main/wordpress-compose.yml -O compose.yml

# Start the containers
podman compose up -d

# Apply the alias
alias wp='podman exec -it wordpress wp --allow-root'

# Create a config file
wp config create \
  --dbname=wordpress \
  --dbuser=wordpress \
  --dbpass=wordpress \
  --dbhost=db

# Install Wordpress
wp core install \
  --url=localhost:8080 \
  --title='Wordpress Test' \
  --admin_user=admin \
  --admin_email=admin@example.com
````

Again, visit [localhost:8080][def] to access the web UI.

[def]: http://localhost:8080
[def2]: http://localhost:8025
