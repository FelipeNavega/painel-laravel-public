FROM php:8.2-apache

# Instala dependências e extensões
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd

# Configura Apache
RUN a2enmod rewrite
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configura diretório de trabalho
WORKDIR /var/www/html

# Copia a auth.json pré-configurada
COPY auth.json /root/.composer/auth.json

# Copia o código fonte e arquivos de configuração
COPY . .

# Definir permissões adequadas
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Instala dependências do PHP
RUN composer install --no-interaction --no-dev

# Expõe a porta 80
EXPOSE 80

# Inicia o servidor Apache
CMD ["apache2-foreground"] 
