#!/bin/bash
set -e

# Criar diretório docker se não existir
mkdir -p docker

# Criar diretórios necessários
mkdir -p storage/app
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Configuração do Apache
cat > docker/000-default.conf << 'EOL'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Criar arquivo auth.json
cat > auth.json << 'EOL'
{
    "http-basic": {
        "classic-theme.filapanel.com": {
            "username": "skay_1994@yahoo.com.br",
            "password": "0b33cd45-5047-4897-8ac6-6a797d7f1849"
        }
    }
}
EOL

# Ajustar permissões
chmod -R 777 storage
chmod -R 777 bootstrap/cache

echo "Configuração concluída com sucesso!" 