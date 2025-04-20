# Estágio 1: Construção
FROM php:8.2-cli AS builder

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip \
        dom

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY composer.* ./
RUN composer install --no-scripts --no-autoloader --no-dev
COPY . .
RUN composer dump-autoload --optimize --no-dev

# Estágio 2: Produção
FROM php:8.2-fpm

# Instalar dependências de runtime
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip \
        dom \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar Nginx e aplicação
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
WORKDIR /var/www/html
COPY --from=builder /app /var/www/html

# Ajustar permissões
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80
CMD ["/usr/local/bin/start.sh"]
