# config/initializers/00_account_patches.rb
Rails.application.config.to_prepare do
  Account.class_eval do
    # Chatwoot v2.9 or custom Stacklab code might expect this method
    unless method_defined?(:enable_feature!)
      def enable_feature!(feature_name)
        # Using the standard flag_shih_tzu or bitmask logic
        # If the model has methods like 'kanban_board_enabled=' use it
        setter_method = "#{feature_name}_enabled="
        if respond_to?(setter_method)
          send(setter_method, true)
        else
          # Fallback to manual bitmask if possible, but setter is better
          Rails.logger.warn "### enable_feature!: #{feature_name} not found as setter, skipping ###"
        end
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
