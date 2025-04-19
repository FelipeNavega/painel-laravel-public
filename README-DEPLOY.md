# Deploy Rápido no Coolify

Este é um guia simplificado para fazer o deploy deste projeto Laravel no Coolify.

## Passos para Deploy

1. Execute o script de setup:
   ```
   ./setup.sh
   ```
   
2. No Coolify, crie um novo projeto e recurso:
   - Escolha "Docker Compose"
   - Use o arquivo `docker-compose.yml` deste projeto
   
3. Configure as variáveis de ambiente:
   - APP_KEY: Chave da aplicação Laravel
   - DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD: Configurações do banco de dados
   
4. Defina a porta 80 para acesso externo

5. Clique em "Deploy"

## Solução de Problemas

Se houver problemas com permissões:
```
chmod -R 777 storage bootstrap/cache
```

## Comandos Úteis

Para executar migrações:
```
docker-compose exec app php artisan migrate
```

Para limpar cache:
```
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
``` 