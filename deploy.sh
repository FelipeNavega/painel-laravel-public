#!/bin/bash
set -e

# Este script é executado pelo Coolify antes do deploy

echo "=== Iniciando preparação para deploy no Coolify ==="

# Executar script de preparação
./prepare-deploy.sh

# Configurando o .env para o banco de dados
cat > .env << EOL
APP_NAME=Laravel
APP_ENV=production
APP_KEY=${APP_KEY:-base64:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=}
APP_DEBUG=false
APP_URL=${APP_URL:-http://localhost}

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=${DB_CONNECTION:-mysql}
DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-laravel}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOL

# Aplicar permissões corretas
chmod -R 775 bootstrap/cache storage

echo "=== Preparação para deploy concluída ===" 