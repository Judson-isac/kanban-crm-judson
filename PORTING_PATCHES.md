# Configuration Patches for Kanban

## 1. config/routes.rb
Add this block inside the `namespace :v1` scope (around accounts):

```ruby
          resources :kanban_items, only: [:index, :show, :create, :update, :destroy] do
            collection do
              post :reorder
              get :debug
              get :reports
              get :search
              get :filter
              get :export
              post :import_preview
              post :import
              post :bulk_move_items
              post :bulk_assign_agent
              post :bulk_set_priority
            end
            member do
              post :move_to_stage
              post :move
              post :create_checklist_item
              post :create_note
              get :get_notes
              patch :update_note
              delete :delete_note
              get :get_checklist
              delete :delete_checklist_item
              post :toggle_checklist_item
              patch :update_checklist_item
              post :assign_agent
              delete :remove_agent
              get :assigned_agents
              post :change_status
              post :assign_agent_to_checklist_item
              delete :remove_agent_from_checklist_item
              get :time_report
              get :stage_time_breakdown
              post :duplicate_checklist
              get :search_checklist
              get :checklist_progress_by_agent
              get :counts
            end
          end

          resources :offers, only: [:index, :show, :create, :update, :destroy] do
            collection do
              get :search
            end
          end

          resource :kanban_config, only: [:index, :show, :create, :update, :destroy] do
            member do
              post :test_webhook
            end
          end

          resources :funnels do
            member do
              get :stage_stats
            end
            resources :kanban_items, only: [:index]
          end

          namespace :kanban do
            resources :items do
              resources :attachments, only: [:index, :create, :destroy]
              resources :note_attachments, only: [:create, :destroy]
            end
            resources :funnels
            resources :stages
            resources :automations
          end
```

And also add:
```ruby
      # Kanban Automations
      resources :kanban_automations
```

## 2. config/features.yml
Add this entry:

```yaml
- name: kanban_board
  display_name: Kanban Board
  enabled: true
```

## 3. app/models/account.rb
Add these associations:

```ruby
  has_many :kanban_items, dependent: :destroy_async
  has_many :funnels, dependent: :destroy_async
  has_many :kanban_configs, dependent: :destroy_async
```
