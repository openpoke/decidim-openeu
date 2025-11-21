# frozen_string_literal: true

require "rails_helper"

describe "User verification" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization, available_authorizations: [:wp_authorization_handler]) }
  let!(:awesome_config) { create(:awesome_config, organization:, var: :admins_available_authorizations, value: [:wp_authorization_handler]) }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "displays the WP authorization form" do
    visit decidim_verifications.new_authorization_path(handler: "wp_authorization_handler")
    expect(page).to have_content("Verify with Work package authorization")
    expect(page).to have_content("This verification method is issued only by administrators")
    expect(page).to have_no_content("Work package number")
    page.find_button("Send", visible: :hidden).execute_script("this.style.display = 'block';")
    click_on "Send"
    expect(page).to have_content("Only administrators can authorize users")
    expect(Decidim::Authorization.count).to eq(0)
  end

  context "when accessed from admin controller" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    it "allows to submit the WP authorization form" do
      visit decidim_admin.officializations_path
      click_on "Work package authorization"
      expect(page).to have_content("Work package number")
      fill_in "Work package number", with: "5"
      click_on "Authorize"
      expect(page).to have_content("authorized with Work package authorization")
      expect(Decidim::Authorization.count).to eq(1)
    end
  end
end
