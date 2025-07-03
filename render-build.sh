#!/bin/bash
set -euo pipefail

composer install --no-interaction --no-dev --optimize-autoloader
php bin/console cache:clear --no-warmup --env=prod
php bin/console cache:warmup --env=prod