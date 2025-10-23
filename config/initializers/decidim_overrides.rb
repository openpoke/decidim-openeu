# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Devise::SessionsController.include(SessionsControllerOverride)
  Decidim::Meetings::MeetingsController.include(MeetingsControllerOverride)
  Decidim::Meetings::DatesAndMapCell.include(DatesAndMapCellOverride)
end
