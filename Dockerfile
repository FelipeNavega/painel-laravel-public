# Estágio 1: Construção com Composer + extensões necessárias
FROM php:8.2-cli AS composer

# Instalar dependências para extensão intl
RUN apt-get update && apt-get install -y \
  libicu-dev \
  zip \
  unzip \
  git

# Instalar a extensão intl
RUN docker-php-ext-configure intl && \
  docker-php-ext-install intl

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copiar arquivos de dependências
COPY composer.* ./

# Instalar dependências
RUN composer install --no-scripts --no-autoloader --no-dev

# Copiar resto do código
COPY . .
RUN composer dump-autoload --optimize --no-dev

# Estágio 2: Imagem final com PHP-FPM e Nginx
FROM php:8.2-fpm

# Instalar dependências
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  libicu-dev \
  zip \
  unzip \
  nginx \
  && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configurar Nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos do projeto
COPY . .
COPY --from=composer /app/vendor /var/www/html/vendor

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
  && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar e configurar script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Expor porta 80
EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
