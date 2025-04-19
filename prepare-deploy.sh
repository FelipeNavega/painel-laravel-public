#!/bin/bash
set -e

# Este script prepara o ambiente para deploy no Coolify

echo "=== Preparando ambiente para deploy no Coolify ==="

# Certificar que todas as diretórios de storage existem
mkdir -p storage/app
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs

# Ajusta permissões
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Copiar auth.json para o lugar certo dentro do container
echo "Configurando auth.json para o Composer"
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

echo "=== Ambiente preparado com sucesso ===" 