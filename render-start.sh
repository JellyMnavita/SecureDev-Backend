#!/bin/bash
set -euo pipefail

# Migrations de base de données (optionnel)
php bin/console doctrine:migrations:migrate --no-interaction

# Démarrer le serveur PHP
php -S 0.0.0.0:${PORT} -t public