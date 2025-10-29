# frozen_string_literal: true

# Multiselect for street verificator
Decidim::Verifications.register_workflow(:wp_authorization_handler) do |workflow|
  workflow.form = "WpAuthorizationHandler"
  # workflow.action_authorizer = "WpActionAuthorizer"

  # workflow.options do |options|
  #   options.attribute :wp, type: :string
  # end
end
