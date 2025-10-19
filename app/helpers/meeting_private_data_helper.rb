# frozen_string_literal: true

module MeetingPrivateDataHelper
  def private_data_allowed?(meeting)
    return true if current_user&.admin?

    required_handlers = meeting.permissions&.dig("view_private_data", "authorization_handlers")
    return true if required_handlers.blank?
    return false unless current_user

    Decidim::Authorization.where(user: current_user, name: required_handlers.keys).any?(&:granted?)
  end
end
