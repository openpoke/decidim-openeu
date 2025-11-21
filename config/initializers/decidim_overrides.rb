# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Devise::SessionsController.include(SessionsControllerOverride)
  Decidim::Devise::RegistrationsController.include(SessionsControllerOverride)
  Decidim::Meetings::MeetingsController.include(MeetingsControllerOverride)
  Decidim::Meetings::DatesAndMapCell.include(DatesAndMapCellOverride)

  # rubocop:disable Metrics/CyclomaticComplexity
  # Override followers to include participatory space and component followers (originally only participatory space)
  Decidim::Followable.module_eval do
    def followers
      query = super
      has_space = !is_a?(Decidim::Component) && respond_to?(:participatory_space) && participatory_space.present? && participatory_space.respond_to?(:followers)
      has_component = respond_to?(:component) && component.present? && component.respond_to?(:followers)
      query = query.or(component.followers) if has_component
      query = query.or(participatory_space.followers) if has_space
      has_space || has_component ? query.distinct : query
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  Decidim::Component.include(Decidim::Followable)
end
