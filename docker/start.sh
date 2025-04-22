#!/bin/bash
set -e

# Inicia PHP-FPM em foreground
php-fpm -D

# Aguarda 2 segundos para garantir inicialização
sleep 2

# Verifica se o PHP-FPM está rodando
if ! pgrep "php-fpm" > /dev/null; then
    echo "ERRO: PHP-FPM não iniciou"
    exit 1
fi

# Inicia Nginx em foreground
nginx -g 'daemon off;'