#!/bin/bash
set -euo pipefail

# Install PHP extensions nécessaires (exemple pour PostgreSQL)
sudo apt-get update && sudo apt-get install -y \
    libpq-dev \
    && sudo docker-php-ext-install pdo pdo_pgsql

# Installation des dépendances
composer install --no-dev --optimize-autoloader --no-interaction

# Warmup du cache
php bin/console cache:clear --env=prod
php bin/console assets:install public