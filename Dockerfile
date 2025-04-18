# Estágio de construção com todas as dependências necessárias
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

# Copiar arquivos de dependências primeiro (para melhor uso do cache)
COPY composer.* ./

# Instalar dependências com verificação de extensões
RUN composer check-platform-reqs && \
    composer install --no-scripts --no-autoloader --no-dev -vvv

# Copiar todo o código fonte
COPY . .

# Otimizar autoloader
RUN composer dump-autoload --optimize --no-dev

# Estágio de produção final
FROM php:8.2-fpm

# Instalar dependências de runtime
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libzip-dev \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar Nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

# Copiar aplicação do estágio de construção
COPY --from=builder /app /var/www/html

# Configurar permissões
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache \
    && chmod -R 775 \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80
CMD ["/usr/local/bin/start.sh"]
