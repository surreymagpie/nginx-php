# First build stage to compile Geos PHP extension
FROM docker.io/alpine:3.19.0 AS geos-build

RUN apk add --no-cache \
	git \
	geos-dev \
	g++ \
	make \
	php83-dev

RUN ln -s /usr/bin/phpize83 /usr/bin/phpize

RUN git clone https://git.osgeo.org/gitea/geos/php-geos.git /tmp/php-geos;
WORKDIR /tmp/php-geos

RUN ./autogen.sh
RUN ./configure --with-php-config=/usr/bin/php-config83
RUN make

# Second stage to build working container image
FROM docker.io/alpine:3.19.0

EXPOSE 80 443

RUN apk add --no-cache \
	bash \
	curl \
	geos \
	gettext \
	git \
	mariadb-client \
	nginx \
	openssh-client \
	php83 \
	php83-bcmath \
	php83-calendar \
	php83-curl \
	php83-ctype \
	php83-exif \
	php83-ffi \
	php83-fileinfo \
	php83-fpm \
	php83-ftp \
	php83-gd \
	php83-gettext \
	php83-iconv \
	php83-intl \
	php83-mysqli \
	php83-opcache \
	php83-pcntl \
	php83-pdo_mysql \
	php83-pecl-apcu \
	php83-pecl-imagick \
	php83-pecl-uploadprogress \
	php83-phar \
	php83-posix \
	php83-session \
	php83-shmop \
	php83-simplexml \
	php83-sockets \
	php83-sodium \
	php83-sysvmsg \
	php83-sysvsem \
	php83-sysvshm \
	php83-tokenizer \
	php83-xml \
	php83-xmlwriter \
	php83-xmlreader\
	php83-tokenizer \
	php83-xsl \
	php83-zip \
	rsync

# Default nginx config
COPY default.template /etc/nginx/http.d/default.template
COPY nginx.conf /etc/nginx/nginx.conf

# Default php-fpm config
COPY www.conf /etc/php83/php-fpm.d/www.conf

# Copy artifact built in first stage
COPY --from=geos-build /tmp/php-geos/modules/geos.so /usr/lib/php83/modules/
RUN echo 'extension=geos' > /etc/php83/conf.d/geos.ini

# Install Composer
COPY --from=docker.io/composer/composer:latest-bin /composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN ln -s /usr/bin/php83 /usr/bin/php

# Install drush globally
RUN wget https://github.com/drush-ops/drush/releases/download/8.4.12/drush.phar \
	&& chmod +x drush.phar \
	&& mv drush.phar /usr/local/bin/drush

# Install Wordpress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Support Mailhog for email testing
RUN sed -i 's/;sendmail_path =/sendmail_path = \/usr\/sbin\/sendmail -S mailhog:1025/' /etc/php83/php.ini 

# Increase PHP memory to 256M
RUN sed -i "s/^memory_limit\ =\ 128M/memory_limit\ =\ 256M/" /etc/php83/php.ini

# Init script
COPY start.sh /start.sh

WORKDIR /var/www/html

STOPSIGNAL SIGKILL

CMD /start.sh
