FROM serversideup/php:8.3-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1

USER root

# Instala Node.js e dependências
RUN apt-get update && apt-get install -y \
    nodejs \
    git \
    unzip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copia primeiro apenas composer.json e composer.lock
WORKDIR /var/www/html
COPY composer.json composer.lock ./

# Verifica e instala dependências do Composer
RUN set -x \
    && echo "Instalando dependências do Composer..." \
    && composer config --global --auth github-oauth.github.com ${GITHUB_TOKEN:-''} \
    && composer diagnose \
    && composer install --no-scripts --no-autoloader --no-dev --verbose \
    || composer install --no-scripts --no-autoloader --no-dev --verbose --ignore-platform-reqs

# Copia o resto dos arquivos e gera o autoloader
COPY . .
RUN composer dump-autoload --optimize --no-dev \
    && chown -R www-data:www-data /var/www/html

# Instala dependências do frontend e compila assets
USER www-data
RUN if [ -f package.json ]; then npm install && npm run build; fi

# O container ServersideUp já configura o servidor web
# na porta 8080 e inicia o PHP-FPM e Nginx automaticamente 
