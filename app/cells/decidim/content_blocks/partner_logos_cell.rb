# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class PartnerLogosCell < Cell::ViewModel
      def load_partners
        YAML.load_file(Rails.root.join("config/partners.yml"))
      rescue StandardError => e
        Rails.logger.error "Failed to load partners: #{e.message}"
        { "members" => [], "associated_partners" => [] }
      end
    end
  end
end
