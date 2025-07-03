FROM php:8.2-apache

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy only composer files first (optimize Docker cache)
COPY composer.json composer.lock symfony.lock ./

# Install dependencies without scripts
RUN composer install --no-dev --no-scripts --no-autoloader --optimize-autoloader

# Copy all files
COPY . .

# Generate optimized autoloader
RUN composer dump-autoload --optimize --no-dev

# Execute necessary Symfony commands manually
RUN php bin/console cache:clear \
    && php bin/console assets:install public

# Configure Apache
RUN a2enmod rewrite
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Set permissions
RUN chown -R www-data:www-data var public