# Estágio 1: PHP CLI para build e instalação de dependências
FROM php:8.2-cli AS builder

# Instalar dependências para extensões necessárias
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  libicu-dev \
  zip \
  unzip

# Instalar todas as extensões PHP necessárias
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Configurar diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY composer.* ./

# Instalar dependências (agora com a extensão intl disponível)
RUN composer install --no-scripts --no-autoloader --no-dev

# Copiar todo o código da aplicação
COPY . .

# Gerar autoloader otimizado
RUN composer dump-autoload --optimize --no-dev

# Estágio 2: PHP-FPM para execução da aplicação
FROM php:8.2-fpm

# Instalar dependências para extensões necessárias
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

# Copiar todo o código da aplicação e dependências do estágio builder
COPY --from=builder /app /var/www/html

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
  && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar e configurar script de inicialização
COPY docker/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Expor porta 80
EXPOSE 80

CMD ["/usr/local/bin/start.sh"]