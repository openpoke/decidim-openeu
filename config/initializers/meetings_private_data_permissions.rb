# frozen_string_literal: true

Rails.application.config.after_initialize do
  meeting_resource = Decidim.find_resource_manifest(:meeting)

  next unless meeting_resource

  meeting_resource.actions = (meeting_resource.actions + ["view_private_data"]).uniq
end
