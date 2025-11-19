# frozen_string_literal: true

module Admin::CreateMeetingOverride
  extend ActiveSupport::Concern

  included do
    alias_method :original_run_after_hooks, :run_after_hooks

    def run_after_hooks
      original_run_after_hooks
      return unless (handler = ENV.fetch("DECIDIM_MEETINGS_PRIVATE_DATA_VERIFIER", nil))

      form = Decidim::Admin::PermissionsForm.from_params({
                                                           permissions: {
                                                             "view_private_data" => {
                                                               authorization_handlers: [handler],
                                                               authorization_handlers_options: {}
                                                             }
                                                           }
                                                         }).with_context(current_organization:)
      Decidim::Admin::UpdateResourcePermissions.call(form, resource) do
        on(:ok) do
          Rails.logger.info("Meeting ##{resource.id} - private data permission 'view_private_data' added with handler #{handler}")
        end
        on(:invalid) do
          Rails.logger.error("Meeting ##{resource.id} - failed to add private data permission 'view_private_data'")
        end
      end
    end
  end
end
