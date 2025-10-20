# frozen_string_literal: true

module MeetingPrivateDataHelper
  def private_data_allowed?(meeting)
    return true if current_user&.admin?
    return true if meeting.permissions&.dig("view_private_data").blank?

    Decidim::ActionAuthorizer.new(current_user, "view_private_data", meeting.component, meeting).authorize.ok?
  end
end
