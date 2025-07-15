# frozen_string_literal: true

require "rails_helper"

describe "Visit the home page", perform_enqueued: true do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let!(:content_block) do
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :partner_logos)
  end

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the home page" do
    expect(page).to have_content("Home")
  end

  it "has the partners content block" do
    expect(page).to have_content("Members")
    expect(page).to have_content("Associated partners")
  end
end
