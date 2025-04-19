#!/bin/bash

# Iniciar PHP-FPM em background
php-fpm -D

# Verificar se o PHP-FPM iniciou corretamente
if [ $? -ne 0 ]; then
    echo "Erro ao iniciar PHP-FPM"
    exit 1
fi

# Iniciar Nginx em foreground
nginx -g "daemon off;" 