# Guia Definitivo de Migração: Kanban para Chatwoot (VPS)

Este guia explica como ativar o Kanban na sua VPS migrando para a imagem Docker da StackLab. Como a sua VPS já está rodando e contém dados de clientes, siga estes passos com a **máxima cautela**. O Kanban **não é um plugin solto**; sua interface visual está compilada irreversivelmente dentro desta imagem Docker específica.

## ⚠️ Avisos Críticos Iniciais
1. **BACKUP DO BANCO DE DADOS**: Faça um dump completo do banco de dados do seu Chatwoot antes de começar. As migrações da StackLab alterarão sua estrutura e isso é um caminho sem volta (sem backup).
2. **Versão do Chatwoot**: Esta imagem (`stacklabdigital/kanban:v2.9`) atualizará seu núcleo do Chatwoot para a **v4.10.1**.

---

## Passo 1: Preparar o Banco de Dados (PostgreSQL)

A imagem da StackLab exige a extensão `vector` no PostgreSQL. Se ela não estiver presente, o contêiner do Rails ficará num ciclo infinito de reinicializações e derrubará o atendimento dos seus clientes.

Acesse o servidor do banco de dados na sua VPS e execute:
```bash
# Entre no container do PostgreSQL (ajuste o nome do container conforme sua instalação, ex: chatwoot-postgres-1)
docker exec -it <NOME_DO_CONTAINER_POSTGRES> psql -U postgres -d chatwoot_production -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

---

## Passo 2: Atualizar a Imagem no `docker-compose.yaml`

No diretório do Chatwoot na sua VPS, abra o `docker-compose.yaml`.

Substitua a imagem oficial em todos os serviços do Chatwoot (normalmente nos blocos `rails`, `sidekiq` e `worker`):
**De:**
```yaml
    image: chatwoot/chatwoot:latest
```
**Para:**
```yaml
    image: stacklabdigital/kanban:v2.9
```

---

## Passo 3: Criar o Patch de Combate ao Bug 500

A imagem da StackLab possui um bug silencioso no login (chama um método inativo `enable_feature!`) que gera um Erro 500, impossibilitando a entrada dos usuários. Para consertá-lo, crie um arquivo chamado `00_account_patches.rb` na pasta principal do Chatwoot da sua VPS com este código exato:

```ruby
# 00_account_patches.rb
Rails.application.config.to_prepare do
  Account.class_eval do
    unless method_defined?(:enable_feature!)
      def enable_feature!(feature_name)
        setter_method = "#{feature_name}_enabled="
        send(setter_method, true) if respond_to?(setter_method)
        save(validate: false)
      end
    end
    unless method_defined?(:enable_feature)
      def enable_feature(feature_name)
        enable_feature!(feature_name)
      end
    end
  end
end
```

---

## Passo 4: Subir a Nova Imagem e Executar as Migrações

Inicie o processo de boot para baixar a imagem v2.9. Ao inicializar, execute as migrações:
```bash
docker compose up -d
docker compose run --rm rails bundle exec rake db:migrate
```

---

## Passo 5: Injetar o Patch e Reiniciar

Com os contêineres rodando, injecte o patch de login que criamos no Passo 3 dentro dos serviços vitais e reinicie:
```bash
# Ajuste os nomes dos containers se necessário
docker cp 00_account_patches.rb chatwoot-rails-1:/app/config/initializers/00_account_patches.rb
docker cp 00_account_patches.rb chatwoot-sidekiq-1:/app/config/initializers/00_account_patches.rb
docker compose restart rails sidekiq worker
```

---

## Passo 6: Ativar o Kanban na Interface (Feature Flag)

Para que o botão "Kanban" ou "Funis" apareça na barra lateral esquerda, a conta do Chatwoot na VPS precisa conter a *Feature Flag* interna `kanban_board` ativada.

Rode o seguinte comando no terminal da sua VPS:
```bash
docker compose run --rm rails bundle exec rails runner "Account.all.each { |a| a.enable_features!('kanban_board') }"
```

> **Nota SuperAdmin:** Somente administradores da conta poderão ver o menu no frontend. O SuperAdmin consegue liberar e desabilitar nativamente ativando/desativando "kanban_board" em `enabled_features` do respectivo `Account`.

---

## Verificação Final
Acesse a aba do seu Chatwoot de produção. O painel logará normalmente e o botão do **Kanban** estará disponível na barra lateral principal (agora já visível na versão PC ou acessível no `/app/accounts/x/kanban`).
