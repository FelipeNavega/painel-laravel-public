FROM serversideup/php:8.3-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_ALLOW_SUPERUSER=1

USER root

# Instala Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs git unzip

# Copia os arquivos da aplicação
COPY . /var/www/html/
WORKDIR /var/www/html

# Ajusta permissões
RUN chown -R www-data:www-data /var/www/html

# Instala dependências do PHP
RUN php -d memory_limit=-1 /usr/bin/composer install --no-interaction --optimize-autoloader --no-dev --verbose

# Instala dependências do frontend e compila assets
USER www-data
RUN npm install
RUN npm run build

# O container ServersideUp já configura o servidor web
# na porta 8080 e inicia o PHP-FPM e Nginx automaticamente 
