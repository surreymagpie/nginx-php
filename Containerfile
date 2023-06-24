# First build stage to compile Geos PHP extension
FROM docker.io/alpine:latest AS geos-build

RUN apk add --no-cache \
	git \
	geos-dev \
	g++ \
	make \
	php82-dev

RUN ln -s /usr/bin/phpize82 /usr/bin/phpize

RUN git clone https://git.osgeo.org/gitea/geos/php-geos.git /tmp/php-geos;
WORKDIR /tmp/php-geos

RUN ./autogen.sh
RUN ./configure --with-php-config=/usr/bin/php-config82
RUN make

# Second stage to build working container image
FROM docker.io/alpine:latest

EXPOSE 80 443

RUN apk add --no-cache \
	geos \
	nginx \
	php82 \
	php82-bcmath \
	php82-calendar \
	php82-curl \
	php82-ctype \
	php82-exif \
	php82-ffi \
	php82-fileinfo \
	php82-fpm \
	php82-ftp \
	php82-gd \
	php82-gettext \
	php82-iconv \
	php82-intl \
  	php82-mysqli \
	php82-opcache \
	php82-pcntl \
	php82-pdo_mysql \
	php82-pecl-apcu \
	php82-pecl-imagick \
	php82-pecl-uploadprogress \
	php82-phar \
  	php82-posix \
	php82-session \
	php82-shmop \
	php82-simplexml \
	php82-sockets \
	php82-sodium \
	php82-sysvmsg \
	php82-sysvsem \
	php82-sysvshm \
	php82-tokenizer \
	php82-xml \
	php82-xmlwriter \
	php82-xmlreader\
	php82-tokenizer \
	php82-xsl \
	php82-zip

# Default nginx config
COPY default.conf /etc/nginx/http.d/default.conf

# Copy artifact built in first stage
COPY --from=geos-build /tmp/php-geos/modules/geos.so /usr/lib/php82/modules/
RUN echo 'extension=geos' > /etc/php82/conf.d/geos.ini

# Init script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh

