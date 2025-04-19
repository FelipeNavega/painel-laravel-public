# Guia de Deploy no Coolify

Este guia explica como configurar este projeto Laravel para deploy no Coolify.

## Requisitos

- Uma instância do Coolify configurada
- Acesso ao servidor Docker Registry (Docker Hub ou outro) para armazenar a imagem Docker

## Configuração no Coolify

### 1. Crie um novo projeto no Coolify:

- Acesse o painel do Coolify
- Clique em "Projetos" e depois em "+ Add"
- Dê um nome ao projeto e clique em "Create"

### 2. Adicione um novo recurso:

- Escolha o ambiente (development, staging ou production)
- Clique em "Add New Resource"
- Em "Docker based", selecione "Docker Compose"
- Selecione o servidor onde deseja fazer o deploy
- Escolha "Standalone Docker (coolify)" como destino

### 3. Configure o Docker Compose:

- Use o arquivo `docker-compose.yml` deste projeto como base
- Certifique-se de que as variáveis de ambiente estão configuradas corretamente
- Marque a opção "Connect to Predefined Network" se estiver usando recursos externos como bancos de dados
- Clique em "Save"

### 4. Configure o domínio:

- Em "Service stack" > "Settings", configure o domínio
- Para imagens ServersideUp, o formato deve ser: `https://seu-dominio.com:8080`
- Salve as configurações

### 5. Configurações de ambiente:

- Configure as variáveis de ambiente necessárias para o projeto:
  - APP_KEY: Sua chave de aplicação Laravel
  - DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD: Configurações do banco de dados
  - REDIS_HOST, REDIS_PASSWORD, REDIS_PORT: Se estiver usando Redis

### 6. Deploy:

- Clique em "Deploy" para iniciar o processo de build e deploy

## Solucionando problemas comuns

### Falha no comando composer install

Se o build falhar durante o comando `composer install` com um erro como:

```
failed to solve: process "/bin/sh -c composer install --no-interaction --optimize-autoloader --no-dev" did not complete successfully
```

Verifique:

1. **Repositório Composer**: Certifique-se de que o Coolify tem acesso aos repositórios composer necessários.

2. **Memória**: Se o composer estiver falhando por falta de memória, você pode:
   - Aumentar a memória disponível para o Coolify na configuração do servidor
   - Usar a variável de ambiente `COMPOSER_MEMORY_LIMIT=-1` no Dockerfile

3. **Permissões**: Verifique se as permissões estão corretas:
   ```
   chown -R www-data:www-data /var/www/html
   ```

4. **Pacotes privados**: Se você estiver usando pacotes privados, configure o auth.json corretamente.

### Problemas de permissão com volumes

Se encontrar problemas de permissão com o volume de armazenamento:

1. Vá para "Storages" no menu lateral e copie o caminho do volume
2. Acesse "Command Center", selecione o servidor e execute:

```
mkdir -p {CAMINHO_DO_VOLUME}/framework/{sessions,views,cache}
chmod -R 775 {CAMINHO_DO_VOLUME}/framework
```

## Conectando a um banco de dados

Para adicionar um banco de dados:

1. Vá para "Projects" > seu projeto
2. Clique em "+ New" para adicionar um novo recurso
3. Selecione o banco de dados desejado (MySQL, PostgreSQL, etc.)
4. Use as credenciais geradas nas configurações do seu aplicativo Laravel
5. **Importante**: Certifique-se de que a opção "Connect to Predefined Network" esteja marcada em ambos os recursos (aplicação e banco de dados)

## Docker Compose

O arquivo `docker-compose.yml` inclui:

- Container principal da aplicação
- Container para o scheduler
- Container para o processamento de filas

Cada container usa a mesma imagem Docker mas com comandos diferentes.

## Dockerfile

O Dockerfile usa a imagem `serversideup/php:8.3-fpm-nginx` como base, que é otimizada para aplicações Laravel.

O build de produção inclui:
- Instalação do Node.js para compilação de assets
- Otimização do PHP com OpCache ativado
- Instalação das dependências do composer otimizadas para produção 