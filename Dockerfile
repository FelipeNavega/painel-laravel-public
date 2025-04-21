# Estágio 1: Build com Composer
FROM composer:2.6 AS composer

WORKDIR /app

# PRIMEIRO: Copiar o composer.json e composer.lock (se existir)
COPY composer.json composer.lock* ./

# DEPOIS: Configurar o repositório e credenciais
RUN composer config repositories.filapanel/classic-theme composer https://classic-theme.filapanel.com
RUN composer config http-basic.classic-theme.filapanel.com contato@criawebstudio.com.br 080cc89b-3406-497a-b3bf-666019fb5629

# Instalar dependências
RUN composer install --no-scripts --no-autoloader --no-dev

# Copiar o restante do código-fonte
COPY . .

# Otimizar autoloader
RUN composer dump-autoload --optimize --no-dev

# Estágio 2: Imagem final
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

# Copiar a aplicação do estágio composer
COPY --from=composer /app /var/www/html

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80
CMD ["/usr/local/bin/start.sh"]
