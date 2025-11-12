# frozen_string_literal: true

module SessionsControllerOverride
  extend ActiveSupport::Concern

  included do
    after_action :csv_auto_verify, only: :create
  end

  def csv_auto_verify
    return unless current_user.organization.available_authorizations.include?("csv_census")

    return unless Decidim::Verifications::CsvDatum.exists?(
      email: current_user.email,
      organization: current_user.organization
    )

    authorization = Decidim::Authorization.find_or_initialize_by(
      user: current_user,
      name: "csv_census"
    )

    authorization.grant! unless authorization.granted?
    # also verify wp_authorization_handler
    if current_user.organization.available_authorizations.include?("wp_authorization_handler")
      wp_authorization = Decidim::Authorization.find_or_initialize_by(
        user: current_user,
        name: "wp_authorization_handler"
      )
      wp_authorization.grant! unless wp_authorization.granted?
    end
  end
end
