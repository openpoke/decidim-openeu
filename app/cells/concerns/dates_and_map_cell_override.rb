# frozen_string_literal: true

module DatesAndMapCellOverride
  extend ActiveSupport::Concern

  included do
    include MeetingPrivateDataHelper

    def location_details
      return unless private_data_allowed?(meeting)

      if display_map?
        static_map
      elsif online?
        cell("decidim/address", meeting, online: true)
      else
        cell("decidim/address", meeting)
      end
    end
  end
end
