# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::Admin::CreateMeeting.include(Admin::CreateMeetingOverride)
end

Rails.application.config.after_initialize do
  meeting_resource = Decidim.find_resource_manifest(:meeting)

  next unless meeting_resource

  meeting_resource.actions = (meeting_resource.actions + ["view_private_data"]).uniq
end
