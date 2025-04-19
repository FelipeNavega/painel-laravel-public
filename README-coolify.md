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

## Solução de problemas de permissão

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