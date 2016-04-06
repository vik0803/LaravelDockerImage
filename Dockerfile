FROM gliderlabs/alpine
MAINTAINER Chris Stretton - https://github.com/cheezykins

RUN apk --no-cache add \
	-X http://dl-4.alpinelinux.org/alpine/edge/testing \ 
	apache2 \
	libwebp \
	php7 \
	php7-apache2 \
	php7-curl \
	php7-gd \
	php7-json \
	php7-mbstring \
	php7-opcache \
	php7-openssl \
	php7-pdo_mysql \
	php7-phar \
	php7-session \
	php7-zlib \
	&& ln -s /usr/bin/php7 /usr/bin/php

RUN apk --no-cache add \
	--virtual build-dependencies \
	curl \
	git \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& mkdir /app /run/apache2 \
	&& sed -i 's/^DocumentRoot ".*/DocumentRoot "\/app\/public"/g' /etc/apache2/httpd.conf \
	&& sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/httpd.conf \
	&& sed -i 's/Directory "\/var\/www\/localhost\/htdocs"/Directory "\/app\/public"/g' /etc/apache2/httpd.conf \
	&& composer create-project \
    --no-ansi \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    laravel/laravel /app ~5.2.0 \
    && rm -f /app/database/migrations/*.php \
    && apk del build-dependencies \
    && chown -R apache:apache /app

ONBUILD RUN composer self-update && cd /app && composer update

EXPOSE 80
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]