FROM php:8.2-apache

WORKDIR /var/www/html

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Copy only composer files first (optimize Docker cache)
COPY composer.json composer.lock symfony.lock ./

# 4. Install runtime component FIRST
RUN composer require symfony/runtime --no-scripts --no-plugins

# 5. Install other dependencies
RUN composer install --no-dev --no-scripts --optimize-autoloader

# 6. Copy all application files
COPY . .

# 7. Fix permissions
RUN chown -R www-data:www-data var public

# 8. Configure Apache
RUN a2enmod rewrite
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# 9. Run necessary Symfony commands
RUN php bin/console cache:clear \
    && php bin/console assets:install public