#!/bin/bash
set -e

# Iniciar PHP-FPM em background
php-fpm -D

# Verificar se o PHP-FPM iniciou corretamente
if ! ps aux | grep -q "php-fpm: master process" | grep -v grep; then
    echo "Erro: PHP-FPM não iniciou corretamente"
    exit 1
fi

# Iniciar Nginx em foreground (mantém o container rodando)
nginx -g 'daemon off;'
