# frozen_string_literal: true

module MeetingsAdminPermissionsOverride
  extend ActiveSupport::Concern

  included do
    alias_method :original_permissions, :permissions

    def permissions
      # Custom override: Allow updating meetings even if they are not official
      if permission_action.subject == :meeting && permission_action.action == :update
        toggle_allow(true)
        return permission_action
      end

      original_permissions
    end
  end
end
