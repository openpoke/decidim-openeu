# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::Admin::CreateMeeting.include(Admin::CreateMeetingOverride)
end

Rails.application.config.after_initialize do
  meeting_component = Decidim.find_component_manifest(:meetings)
  meeting_resource = Decidim.find_resource_manifest(:meeting)

  meeting_component.actions = (meeting_component.actions + ["view_private_data"]).uniq if meeting_component
  meeting_resource.actions = (meeting_resource.actions + ["view_private_data"]).uniq if meeting_resource
end
