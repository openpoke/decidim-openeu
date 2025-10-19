# frozen_string_literal: true

require "rails_helper"

describe "Meeting private data permissions" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:organization) { create(:organization, available_authorizations: ["csv_census"]) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:meeting_component, participatory_space: participatory_process) }

  let!(:meeting) do
    create(:meeting,
           :published,
           :hybrid,
           :embed_in_meeting_page_iframe_embed_type,
           component:,
           address: "Carrer de la Pau 1, Barcelona", location: { en: "Barcelona City Hall" },
           location_hints: { en: "Main entrance, 2nd floor" }, online_meeting_url: "https://meet.example.org/secret-meeting",
           start_time: 1.hour.ago, end_time: 1.hour.from_now)
  end

  let!(:attachment) { create(:attachment, :with_pdf, attached_to: meeting, title: { en: "Meeting Document" }) }

  before do
    switch_to_host(organization.host)
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
  end

  context "when no permissions are set" do
    context "when user is not logged in" do
      before do
        visit resource_locator(meeting).path
      end

      it "shows all data including address, location, location hints" do
        expect(page).to have_content(meeting.address)
        expect(page).to have_content(translated_attribute(meeting.location))
        expect(page).to have_content(translated_attribute(meeting.location_hints))
      end

      it "shows attachments tab" do
        within "#trigger-documents" do
          expect(page).to have_content("Documents")
        end
      end
    end

    context "when user is logged in" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it "shows all data" do
        expect(page).to have_content(meeting.address)
        expect(page).to have_content(translated_attribute(meeting.location))
        expect(page).to have_content(translated_attribute(meeting.location_hints))
      end
    end
  end

  context "when permissions are set for view_private_data" do
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

    context "when user is not logged in" do
      before do
        visit resource_locator(meeting).path
      end

      it "does not show address, location, location_hints" do
        expect(page).to have_no_content(meeting.address)
        expect(page).to have_no_content(translated_attribute(meeting.location))
        expect(page).to have_no_content(translated_attribute(meeting.location_hints))
      end

      it "shows only calendar dates" do
        expect(page).to have_css(".meeting__calendar-container")
        expect(page).to have_css(".meeting__calendar-day")
      end

      it "does not show online meeting URL" do
        expect(page).to have_no_content(meeting.online_meeting_url)
      end

      it "does not show attachments tab" do
        expect(page).to have_no_content("Documents")
      end

      it "shows public data (title, description)" do
        expect(page).to have_content(translated_attribute(meeting.title))
        expect(page).to have_content(strip_tags(translated_attribute(meeting.description)))
      end
    end

    context "when user is logged in but does not have authorization" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it "does not show address, location, location_hints" do
        expect(page).to have_no_content(meeting.address)
        expect(page).to have_no_content(translated_attribute(meeting.location))
        expect(page).to have_no_content(translated_attribute(meeting.location_hints))
      end

      it "does not show online meeting URL" do
        expect(page).to have_no_content(meeting.online_meeting_url)
      end

      it "does not show attachments tab" do
        expect(page).to have_no_content("Documents")
      end
    end

    context "when user has required authorization" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:authorization) { create(:authorization, :granted, user:, name: "csv_census", organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it "shows address, location, location_hints" do
        expect(page).to have_content(meeting.address)
        expect(page).to have_content(translated_attribute(meeting.location))
        expect(page).to have_content(translated_attribute(meeting.location_hints))
      end

      it "shows online meeting URL section" do
        expect(page).to have_content("JOIN MEETING")
      end

      it "shows attachments tab" do
        within "#trigger-documents" do
          expect(page).to have_content("Documents")
        end
      end
    end

    context "when user is admin" do
      let(:admin) { create(:user, :admin, :confirmed, organization:) }

      before do
        login_as admin, scope: :user
        visit resource_locator(meeting).path
      end

      it "shows all private data regardless of permissions" do
        expect(page).to have_content(meeting.address)
        expect(page).to have_content(translated_attribute(meeting.location))
        expect(page).to have_content(translated_attribute(meeting.location_hints))
      end

      it "shows attachments tab" do
        within "#trigger-documents" do
          expect(page).to have_content("Documents")
        end
      end
    end
  end

  context "when meeting is closed" do
    let!(:closed_meeting) do
      create(:meeting,
             :published,
             :closed,
             component:,
             address: "Carrer de la Pau 1, Barcelona",
             location: { en: "Barcelona City Hall" }, location_hints: { en: "Main entrance, 2nd floor" },
             closing_report: { en: "Meeting summary and conclusions" }, attendees_count: 10, closing_visible: true)
    end

    before do
      stub_geocoding_coordinates([closed_meeting.latitude, closed_meeting.longitude])
      closed_meeting.create_resource_permission(
        permissions: {
          "view_private_data" => {
            "authorization_handlers" => {
              "csv_census" => {}
            }
          }
        }
      )
    end

    context "when user does not have authorization" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(closed_meeting).path
      end

      it "does not show minutes (closing report)" do
        expect(page).to have_no_content(translated_attribute(closed_meeting.closing_report))
      end

      it "does not show address and attachments" do
        expect(page).to have_no_content(closed_meeting.address)
        expect(page).to have_no_content("Documents")
      end
    end

    context "when user has authorization" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:authorization) { create(:authorization, :granted, user:, name: "csv_census", organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(closed_meeting).path
      end

      it "shows minutes (closing report)" do
        expect(page).to have_content(translated_attribute(closed_meeting.closing_report))
      end

      it "shows all private data" do
        expect(page).to have_content(closed_meeting.address)
        expect(page).to have_content(translated_attribute(closed_meeting.location))
      end
    end
  end
end
