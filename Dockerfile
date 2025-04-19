FROM composer:2.6 as composer

COPY . /app/
WORKDIR /app

RUN composer install --optimize-autoloader --no-dev

FROM php:8.2-fpm

# Instalar dependências
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Configurar Nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos do projeto
COPY . .
COPY --from=composer /app/vendor /var/www/html/vendor

# Otimizar Laravel
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar e configurar script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Expor porta 80
EXPOSE 80

CMD ["/usr/local/bin/start.sh"] 