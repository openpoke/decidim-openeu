# frozen_string_literal: true

module SessionsControllerOverride
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/LexicallyScopedActionFilter
    after_action :csv_auto_verify, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end

  def csv_auto_verify
    return unless user
    return unless user.organization.available_authorizations.include?("csv_census")

    # Match CSV emails case-insensitively (Postgres ILIKE)
    return unless Decidim::Verifications::CsvDatum.where(
      "email ILIKE ? AND decidim_organization_id = ?",
      user.email,
      user.organization.id
    ).exists?

    authorization = Decidim::Authorization.find_or_initialize_by(
      user: user,
      name: "csv_census"
    )

    authorization.grant! unless authorization.granted?
    # also verify wp_authorization_handler
    return unless user.organization.available_authorizations.include?("wp_authorization_handler")

    wp_authorization = Decidim::Authorization.find_or_initialize_by(
      user: user,
      name: "wp_authorization_handler"
    )
    wp_authorization.grant! unless wp_authorization.granted?
  end

  private

  def user
    @user ||= current_user || Decidim::User.find_by(email: params.dig("user", "email"))
  end
end
