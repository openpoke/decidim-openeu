# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-meetings",
    files: {
      "/app/controllers/decidim/meetings/meetings_controller.rb" => "da1a19e72fc0692c259671b9fdc8dc8b",
      "/app/commands/decidim/meetings/admin/create_meeting.rb" => "970faa493b3086a0feca886de3b45061",
      "/app/cells/decidim/meetings/dates_and_map_cell.rb" => "7f5aa4ad0f98304dafaf2a719fa146ba",
      "/app/cells/decidim/meetings/dates_and_map/show.erb" => "ae848e2178f6f14f718fea92e75d3635",
      "/app/views/decidim/meetings/meetings/_meeting.html.erb" => "ed7310e5cc494445b2b0f7c08affcdd7",
      "/app/permissions/decidim/meetings/admin/permissions.rb" => "739520978c011ee0eb6896166575452b"
    }
  },
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/footer/_main.html.erb" => "2d3ecb9824c197951ef8fd7a77bed7d0"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
