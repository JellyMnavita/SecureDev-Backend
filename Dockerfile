FROM php:8.2-apache

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first (optimize Docker cache)
COPY composer.json composer.lock ./

# Install PHP dependencies (without scripts)
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Copy all files
COPY . .

# Now run scripts
RUN composer run-script post-install-cmd

# Configure Apache
RUN a2enmod rewrite
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Set permissions
RUN chown -R www-data:www-data var