# frozen_string_literal: true

# NOTE: Remove when upgrading to v0.30

Decidim.content_blocks.register(:assembly_homepage, :highlighted_debates) do |content_block|
  content_block.cell = "decidim/debates/content_blocks/highlighted_debates"
  content_block.public_name_key = "decidim.debates.content_blocks.highlighted_debates.name"
  content_block.component_manifest_name = "debates"
end

Decidim.content_blocks.register(:participatory_process_homepage, :highlighted_debates) do |content_block|
  content_block.cell = "decidim/debates/content_blocks/highlighted_debates"
  content_block.public_name_key = "decidim.debates.content_blocks.highlighted_debates.name"
  content_block.component_manifest_name = "debates"
end
