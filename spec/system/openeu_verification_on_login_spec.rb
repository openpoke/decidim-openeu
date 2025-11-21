# frozen_string_literal: true

require "rails_helper"

describe "User verification on login" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization, available_authorizations: [:wp_authorization_handler, :csv_census]) }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
  end

  it "auto verifies the user if a CSV datum exists with their email" do
    create(:csv_datum, email: user.email, organization:)

    visit decidim.new_user_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: user.password
    within "#session_new_user" do
      click_on "Log in"
    end
    expect(Decidim::Authorization.count).to eq(2)
    authorization_names = Decidim::Authorization.pluck(:name)
    expect(authorization_names).to include("csv_census")
    expect(authorization_names).to include("wp_authorization_handler")
  end

  it "does not verify the user if no CSV datum exists with their email" do
    visit decidim.new_user_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: user.password
    within "#session_new_user" do
      click_on "Log in"
    end
    expect(Decidim::Authorization.count).to eq(0)
  end

  it "verifies the user when a new registration matches a CSV datum" do
    create(:csv_datum, email: "new_user@example.com", organization: organization)
    visit decidim.new_user_registration_path
    fill_in "Your name", with: "New User"
    fill_in "Your email", with: "new_user@example.com"
    fill_in "Password", with: "decidim123456789"
    check "By signing up you agree to the terms of service."
    check "Receive an occasional newsletter with relevant information"
    within "#register-form" do
      click_on "Create an account"
    end
    expect(Decidim::Authorization.count).to eq(2)
    authorization_names = Decidim::Authorization.pluck(:name)
    expect(authorization_names).to include("csv_census")
    expect(authorization_names).to include("wp_authorization_handler")
  end

  it "does not verify the user when a new registration does not match a CSV datum" do
    visit decidim.new_user_registration_path
    fill_in "Your name", with: "Another User"
    fill_in "Your email", with: "another_user@example.com"
    fill_in "Password", with: "decidim123456789"
    check "By signing up you agree to the terms of service."
    check "Receive an occasional newsletter with relevant information"
    within "#register-form" do
      click_on "Create an account"
    end
    expect(Decidim::Authorization.count).to eq(0)
  end

  it "shows an error if password is too weak" do
    visit decidim.new_user_registration_path
    fill_in "Your name", with: "User"
    fill_in "Your email", with: "new_user@example.com"
    fill_in "Password", with: "password"
    check "By signing up you agree to the terms of service."
    check "Receive an occasional newsletter with relevant information"
    within "#register-form" do
      click_on "Create an account"
    end
    expect(page).to have_content("There is an error in this field")
  end
end
