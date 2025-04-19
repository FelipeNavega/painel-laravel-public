# Guia de Deploy no Coolify

Este guia explica como configurar este projeto Laravel para deploy no Coolify.

## Requisitos

- Uma instância do Coolify configurada
- Acesso ao servidor Docker Registry (Docker Hub ou outro) para armazenar a imagem Docker

## Pré-deploy

Antes de iniciar o deploy no Coolify, execute localmente:

```bash
./prepare-deploy.sh
```

Este script irá:
1. Criar as pastas necessárias para o storage
2. Configurar o arquivo auth.json para acessar pacotes privados
3. Ajustar as permissões necessárias

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

### 4. Configure variáveis de ambiente para pacotes privados:

É necessário configurar as seguintes variáveis no Coolify:

```
GITHUB_TOKEN=seu_token_github_para_pacotes_privados
```

### 5. Configure o pré-deploy e pós-deploy:

No painel do Coolify, configure:

**Pre-Deployment Command:**
```bash
chmod +x deploy.sh && ./deploy.sh
```

### 6. Configure o domínio:

- Em "Service stack" > "Settings", configure o domínio
- Para imagens ServersideUp, o formato deve ser: `https://seu-dominio.com:8080`
- Salve as configurações

### 7. Configurações de ambiente:

- Configure as variáveis de ambiente necessárias para o projeto:
  - APP_KEY: Sua chave de aplicação Laravel
  - DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD: Configurações do banco de dados
  - REDIS_HOST, REDIS_PASSWORD, REDIS_PORT: Se estiver usando Redis

### 8. Deploy:

- Clique em "Deploy" para iniciar o processo de build e deploy

## Solucionando problemas comuns

### Falha no comando composer install

Se o build falhar durante o comando `composer install` com um erro como:

```
failed to solve: process "/bin/sh -c composer install" did not complete successfully
```

Verifique:

1. **Repositório Composer Privado**: Este projeto depende do pacote privado `filapanel/classic-theme`. Confira se:
   - O arquivo `auth.json` está presente e com as credenciais corretas
   - Execute `./prepare-deploy.sh` para gerar o arquivo auth.json
   - Configure a variável GITHUB_TOKEN no Coolify se estiver usando pacotes do GitHub

2. **Memória**: Se o composer estiver falhando por falta de memória:
   - Usamos a variável de ambiente `COMPOSER_MEMORY_LIMIT=-1` no Dockerfile
   - Aumente a memória disponível para o Coolify na configuração do servidor

3. **Abordagem Alternativa**: 
   - No Dockerfile modificado, agora usamos uma estratégia em duas etapas para o Composer
   - Primeiro instalamos apenas as dependências e depois copiamos os arquivos
   - Se isto ainda falhar, tente adicionar a flag `--ignore-platform-reqs` no Dockerfile

### Problemas de permissão com volumes

Se encontrar problemas de permissão com o volume de armazenamento:

1. Vá para "Storages" no menu lateral e copie o caminho do volume
2. Acesse "Command Center", selecione o servidor e execute:

```bash
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