# Kanban Porting Guide for Chatwoot

This guide explains how to port the Kanban feature from the StackLab version to your original Chatwoot installation on a VPS.

## Prerequisites
- Access to your VPS terminal or Portainer.
- Ability to run commands inside the Chatwoot container.

## Step 1: Upload Backend Files
Copy the contents of the `app/`, `db/migrate/`, `app/policies/`, `app/services/`, and `app/jobs/` directories from this package to your Chatwoot installation.

If you are using Docker, you can use `docker cp`:
```bash
# Example for one file
docker cp app/models/kanban_item.rb chatwoot_web_1:/app/app/models/
```
*Tip: It's easier to copy the whole directories if you have volume mapping.*

## Step 2: Apply Database Migrations
Run the migrations inside your Rails container:
```bash
docker exec -it chatwoot_web_1 bundle exec rails db:migrate
```

## Step 3: Patch Configuration
Apply the changes described in `PORTING_PATCHES.md` to:
1. `config/routes.rb`: Add the Kanban routes.
2. `config/features.yml`: Add the `kanban_board` feature flag.
3. `app/models/account.rb`: Add the associations.

## Step 4: Frontend (Compiled Assets)
Since the source code for the frontend is not available, you would need to inject the compiled assets.
**Warning:** This part is complex. If your original Chatwoot uses a different version of Node/Vite, the compiled assets might not work directly without manual injection into the main layout.

## Step 5: Restart Services
Restart your Chatwoot containers to apply the changes.
```bash
docker restart chatwoot_web_1 chatwoot_worker_1
```
