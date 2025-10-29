# frozen_string_literal: true

require "rails_helper"

describe "Admin" do
  context "when admin manages census authorizations" do
    let!(:organization) { create(:organization, available_authorizations:) }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let(:available_authorizations) { %w(id_documents postal_letter csv_census dummy_authorization_handler another_dummy_authorization_handler sms) }
    let(:test_user) { create(:user, :confirmed, email: "user@example.org", password: "decidim123456789", organization:) }

    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user

      visit decidim_admin.root_path
      click_on "Participants"
      within_admin_sidebar_menu do
        click_on "Authorizations"
      end
    end

    context "when authorization handlers are available" do
      it "displays the menu entries" do
        within ".sidebar-menu" do
          expect(page).to have_content("Identity documents")
          expect(page).to have_content("Code by postal letter")
          expect(page).to have_content("Organization's census")
        end
      end
    end

    context "when uploading a CSV file" do
      before do
        within ".sidebar-menu" do
          click_on "Organization's census"
        end
      end

      it "displays a successful message" do
        expect(page).to have_content("Current census data")
        expect(page).to have_content("There are no census data.")
        expect(page).to have_content("Upload file")
      end

      it "imports a csv file" do
        attach_file "File", Rails.root.join("lib/assets/valid_emails.csv")
        expect(page).to have_content("Upload file")
        click_on "Upload file"

        expect(page).to have_content("Successfully imported 5 items")
      end

      context "when user logs in" do
        before do
          attach_file "File", Rails.root.join("lib/assets/valid_emails.csv")
          click_on "Upload file"
          visit decidim.root_path
          find_by_id("trigger-dropdown-account").click
          within ".dropdown.dropdown__bottom.main-bar__dropdown" do
            click_on "Log out"
          end
        end

        context "when the email exists in the census" do
          let(:last_authorization) { Decidim::Authorization.last }

          it "authorizes the user" do
            within ".main-bar" do
              click_on "Log in"
            end
            fill_in "Email address", with: test_user.email
            fill_in "Password", with: test_user.password
            within ".form__wrapper-block" do
              click_on "Log in"
            end

            expect(last_authorization.user).to eq(test_user)
            expect(last_authorization.name).to eq("csv_census")
            expect(last_authorization).to be_granted
          end
        end
      end
    end
  end
end
