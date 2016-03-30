FROM php:5.6-apache
MAINTAINER Chris Stretton - https://github.com/cheezykins
RUN a2enmod rewrite
WORKDIR /var/www
RUN apt-get update && apt-get install --no-install-recommends -y \
    zlib1g-dev \
    mysql-client \
    git \
    && docker-php-ext-install -j$(nproc) \
    mbstring \
    zip \
    mysql \
    pdo \
    pdo_mysql \
    && pecl install spl_types \
    && docker-php-ext-enable spl_types \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer create-project \
    --no-ansi \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    laravel/laravel /var/www/html ~5.2.0 \
    && rm -f /var/www/html/database/migrations/*.php \
    /var/www/html/app/Users.php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN chown -R www-data:www-data /var/www/html
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/g' /etc/apache2/apache2.conf
ONBUILD RUN composer self-update && cd /var/www/html && composer update
WORKDIR /var/www/html
