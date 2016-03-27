FROM php:5.6-apache
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
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
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
WORKDIR /var/www/html