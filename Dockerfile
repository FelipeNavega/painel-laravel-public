# Estágio 1: Construção com autenticação segura
FROM php:8.2-cli AS builder

# Declaração das variáveis de build (serão injetadas pelo Coolify)
ARG COMPOSER_USERNAME
ARG COMPOSER_PASSWORD

# Instalar dependências do sistema + extensões PHP
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
    g++ \
    build-essential \
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
RUN apt-get update && apt-get install -y curl
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copiar arquivos de dependências primeiro (para cache)
COPY composer.* ./

# Configurar autenticação via variáveis de build
RUN composer config repositories.filapanel/classic-theme composer https://classic-theme.filapanel.com && \
    composer config http-basic.classic-theme.filapanel.com "${COMPOSER_USERNAME}" "${COMPOSER_PASSWORD}"

# Instalar dependências (as variáveis já estão configuradas)
RUN composer install --no-scripts --no-autoloader --no-dev

# Copiar todo o código fonte
COPY . .

# Otimizar autoloader
RUN composer dump-autoload --optimize --no-dev

# Estágio 2: Produção (imagem final leve)
FROM php:8.2-fpm

# Instalar dependências de runtime + DEV para compilação de extensões
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libzip-dev \
    libxml2-dev \
    libxslt-dev \ 
    libfreetype6-dev \      
    libjpeg62-turbo-dev \   
    libpng-dev \
    libonig-dev \               
    libfreetype6 \
    libjpeg62-turbo \
    libxml2 \
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

RUN apt-get update && apt-get install -y \
    procps \
    net-tools \
    iproute2 \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar aplicação do estágio de construção
COPY --from=builder /app /var/www/html

# Criar diretório para logs do PHP-FPM
RUN mkdir -p /var/log/php-fpm && \
    touch /var/log/php-fpm.log && \
    chown -R www-data:www-data /var/log/php-fpm

# Ajustar permissões
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Verificar a configuração do PHP-FPM
RUN php-fpm -t

# Script de inicialização
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80
CMD ["/usr/local/bin/start.sh"]