# frozen_string_literal: true

require "rails_helper"

describe "Admin manages meeting permissions" do # rubocop:disable RSpec/DescribeClass
  let(:manifest_name) { "meetings" }
  let!(:meeting) do
    create(:meeting,
           :published,
           component: current_component,
           address: "Carrer de la Pau 1, Barcelona",
           location: { en: "Barcelona City Hall" },
           location_hints: { en: "Main entrance, 2nd floor" },
           online_meeting_url: "https://meet.example.org/secret-meeting")
  end

  include_context "when managing a component as an admin" do
    let(:organization) { create(:organization, available_authorizations: ["csv_census"]) }
    let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }
    let!(:component) { create(:component, :published, manifest:, participatory_space:, settings: { resources_permissions_enabled: true }) }
  end

  it "allows admin to set view_private_data permissions" do
    visit current_path

    expect(page).to have_content(translated_attribute(meeting.title))

    within "tr[data-id='#{meeting.id}']" do
      find("a.action-icon--permissions").click
    end

    expect(page).to have_css(".view_private_data-permission")

    within ".view_private_data-permission" do
      expect(page).to have_content("View private meeting details")
      check "component_permissions_permissions_view_private_data_authorization_handlers_csv_census"
    end

    click_on "Submit"

    expect(page).to have_admin_callout("successfully")

    meeting.reload
    expect(meeting.permissions).to be_present
    expect(meeting.permissions["view_private_data"]).to be_present
    expect(meeting.permissions["view_private_data"]["authorization_handlers"]).to have_key("csv_census")
  end

  context "when permissions are already set" do
    before do
      meeting.create_resource_permission(
        permissions: {
          "view_private_data" => {
            "authorization_handlers" => {
              "csv_census" => {}
            }
          }
        }
      )
    end

    it "highlights the permissions link" do
      visit current_path

      within "tr[data-id='#{meeting.id}']" do
        expect(page).to have_css(".action-icon--permissions.action-icon--highlighted")
      end
    end

    it "shows previously selected authorizations" do
      visit current_path

      within "tr[data-id='#{meeting.id}']" do
        find("a.action-icon--permissions").click
      end

      within ".view_private_data-permission" do
        expect(find_field("component_permissions_permissions_view_private_data_authorization_handlers_csv_census", type: "checkbox")).to be_checked
      end
    end

    it "allows admin to remove permissions" do
      visit current_path

      within "tr[data-id='#{meeting.id}']" do
        find("a.action-icon--permissions").click
      end

      within ".view_private_data-permission" do
        uncheck "component_permissions_permissions_view_private_data_authorization_handlers_csv_census"
      end

      click_on "Submit"

      expect(page).to have_admin_callout("successfully")

      meeting.reload
      expect(meeting.permissions.dig("view_private_data", "authorization_handlers")).to be_blank
    end
  end

  context "when admin creates a new meeting" do
    let(:authorization_handler) { "csv_census" }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DECIDIM_MEETINGS_PRIVATE_DATA_VERIFIER", nil).and_return(authorization_handler)
    end

    it "automatically adds view_private_data permission if env variable is set" do
      click_on "New meeting"

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My meeting",
        es: "Mi meeting",
        ca: "El meu meeting"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A description",
        es: "Una descripción",
        ca: "Una descripció"
      )
      select "Online", from: :meeting_type_of_meeting
      fill_in_datepicker :meeting_start_time_date, with: Time.new.utc.strftime("%d/%m/%Y")
      fill_in_timepicker :meeting_start_time_time, with: Time.new.utc.strftime("%H:%M")
      fill_in_datepicker :meeting_end_time_date, with: (Time.new.utc + 2.days).strftime("%d/%m/%Y")
      fill_in_timepicker :meeting_end_time_time, with: (Time.new.utc + 2.days).strftime("%H:%M")
      select "Registration disabled", from: :meeting_registration_type
      click_on "Create"

      expect(page).to have_admin_callout("successfully")

      meeting = Decidim::Meetings::Meeting.last
      expect(meeting.permissions).to be_present
      expect(meeting.permissions["view_private_data"]).to be_present
      expect(meeting.permissions["view_private_data"]["authorization_handlers"]).to have_key("csv_census")
    end

    context "when env variable is not set" do
      let(:authorization_handler) { nil }

      it "does not add view_private_data permission" do
        click_on "New meeting"

        fill_in_i18n(
          :meeting_title,
          "#meeting-title-tabs",
          en: "My meeting",
          es: "Mi meeting",
          ca: "El meu meeting"
        )
        fill_in_i18n_editor(
          :meeting_description,
          "#meeting-description-tabs",
          en: "A description",
          es: "Una descripción",
          ca: "Una descripció"
        )
        select "Online", from: :meeting_type_of_meeting
        fill_in_datepicker :meeting_start_time_date, with: Time.new.utc.strftime("%d/%m/%Y")
        fill_in_timepicker :meeting_start_time_time, with: Time.new.utc.strftime("%H:%M")
        fill_in_datepicker :meeting_end_time_date, with: (Time.new.utc + 2.days).strftime("%d/%m/%Y")
        fill_in_timepicker :meeting_end_time_time, with: (Time.new.utc + 2.days).strftime("%H:%M")
        select "Registration disabled", from: :meeting_registration_type
        click_on "Create"

        expect(page).to have_admin_callout("successfully")

        meeting = Decidim::Meetings::Meeting.last
        expect(meeting.permissions).to be_blank
      end
    end
  end
end
