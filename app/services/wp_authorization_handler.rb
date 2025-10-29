# frozen_string_literal: true

# This class performs a check against the official census database in order
# to verify the citizen's residence.
class WpAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :wp, Integer
  attribute :controller_name, String

  validates :wp, presence: true
  validates :wp, numericality: { only_integer: true, greater_than: 0, less_than: 20 }
  validate :only_from_admin_controller

  def to_partial_path
    "wp_authorization_handler/form"
  end

  def unique_id
    user.id
  end

  def metadata
    {
      wp:
    }
  end

  private

  def only_from_admin_controller
    errors.add(:base, I18n.t("openeu.verifications.non_admin")) unless controller_name == "admin_authorizations"
  end
end
