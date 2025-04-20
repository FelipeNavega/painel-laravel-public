# Estágio 1: Build das dependências
FROM composer:2.6 AS composer

# Configurar repositório e credenciais (usando build secrets)
RUN --mount=type=secret,id=COMPOSER_AUTH \
    composer config repositories.filapanel/classic-theme composer https://classic-theme.filapanel.com && \
    jq -n '{"http-basic":{"classic-theme.filapanel.com":{"username":"contato@criawebstudio.com.br","password":"080cc89b-3406-497a-b3bf-666019fb5629"}}}' > auth.json

WORKDIR /app
COPY composer.* ./

# Instalar dependências principais (incluindo tema)
RUN --mount=type=secret,id=COMPOSER_AUTH \
    composer require filapanel/classic-theme --no-dev --no-scripts --no-autoloader

# Estágio 2: Build final da aplicação
FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
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

# Configurar Nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

# Copiar dependências do estágio composer
COPY --from=composer /app/vendor /var/www/html/vendor
COPY --from=composer /app/auth.json /var/www/html/auth.json

# Copiar código fonte
COPY . .

# Configurar permissões e assets
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && php artisan filament:assets

# Script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80
CMD ["/usr/local/bin/start.sh"]
