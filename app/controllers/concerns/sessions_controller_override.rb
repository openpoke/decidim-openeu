# frozen_string_literal: true

module SessionsControllerOverride
  extend ActiveSupport::Concern

  included do
    after_action :csv_auto_verify, only: :create
  end

  def csv_auto_verify
    return unless current_user.organization.available_authorizations.include?("csv_census")

    record = Decidim::Verifications::CsvDatum.find_or_create_by(
      email: current_user.email,
      organization: current_user.organization
    )
    return unless record

    authorization = Decidim::Authorization.find_or_initialize_by(
      user: current_user,
      name: "csv_census"
    )

    authorization.grant! unless authorization.granted?
  end
end
