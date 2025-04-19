# Estágio de construção para dependências Composer
FROM composer:2.6 as composer

WORKDIR /app
COPY composer.* ./

# Instalação de dependências (para melhor uso de cache)
RUN composer install --no-scripts --no-autoloader --no-dev

# Copia o resto do código da aplicação
COPY . .
RUN composer dump-autoload --optimize --no-dev

# Estágio principal com PHP e Nginx
FROM php:8.2-fpm

# Instalar dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  libzip-dev \
  zip \
  unzip \
  nginx \
  && docker-php-ext-install \
  pdo_mysql \
  mbstring \
  exif \
  pcntl \
  bcmath \
  gd \
  dom \
  xml \
  zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configurar Nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos do projeto e dependências
COPY --from=composer /app /var/www/html

# Gerar chave da aplicação Laravel se necessário
RUN if [ -f ".env" ] && [ ! -z "$(grep APP_KEY=base64:.* .env)" ]; then \
  echo "App key exists"; \
  elif [ -f ".env" ]; then \
  php artisan key:generate; \
  else \
  cp .env.example .env && php artisan key:generate; \
  fi

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
  && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Script de inicialização
COPY --chown=root:root <<'EOF' /usr/local/bin/start.sh
#!/bin/bash
set -e

# Iniciar PHP-FPM em background
php-fpm -D

# Iniciar Nginx em foreground
nginx -g 'daemon off;'
EOF

RUN chmod +x /usr/local/bin/start.sh

# Expor porta 80
EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
