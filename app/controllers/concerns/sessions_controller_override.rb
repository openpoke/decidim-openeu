# frozen_string_literal: true

module Decidim
  module Devise
    class SessionsControllerOverride < ::Devise::SessionsController
      def create
        super do |user|
          verify_users_after_sign_in(user)
        end
      end

      private

      def verify_users_after_sign_in(user)
        record = CsvDatum.find_or_create_by(email: user.email, organization: user.organization)
        return unless record

        authorization = Decidim::Authorization.find_or_initialize_by(
          user:,
          name: "csv_census"
        )

        authorization.grant! unless authorization.granted?
      end
    end
  end
end
