# frozen_string_literal: true

Decidim.content_blocks.register(:homepage, :partner_logos) do |content_block|
  content_block.cell = "decidim/content_blocks/partner_logos"
  content_block.public_name_key = "decidim.content_blocks.partner_logos.name"
  content_block.default!
end
