FROM serversideup/php:8.3-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

# Instala Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Copia os arquivos da aplicação
COPY --chown=www-data:www-data . /var/www/html

USER www-data

# Instala dependências do frontend e compila assets
RUN npm install
RUN npm run build

# Instala dependências do PHP otimizadas para produção
RUN composer install --no-interaction --optimize-autoloader --no-dev

# O container ServersideUp já configura o servidor web
# na porta 8080 e inicia o PHP-FPM e Nginx automaticamente 
