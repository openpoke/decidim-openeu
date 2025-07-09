# frozen_string_literal: true

require "rails_helper"

describe "Visit the home page", perform_enqueued: true do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the home page" do
    expect(page).to have_content("Home")
  end

  it "changes the locale to the chosen one" do
    within_language_menu do
      click_on "Euskara"
    end

    expect(page).to have_content("Hasiera")
  end
end
