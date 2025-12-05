# frozen_string_literal: true

require "rails_helper"
require_relative "shared/meeting_permissions_examples"

describe "Meeting private data permissions" do # rubocop:disable RSpec/DescribeClass
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

      it_behaves_like "shows all info"
    end

    context "when user is logged in" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it_behaves_like "shows all info"
    end
  end

  context "when permissions are set in the meeting" do
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

    it_behaves_like "permissions are set"
  end

  context "when permissions are set in the component" do
    before do
      component.update!(
        permissions: {
          "view_private_data" => {
            "authorization_handlers" => {
              "csv_census" => {}
            }
          }
        }
      )
    end

    it_behaves_like "permissions are set"
  end

  context "when meeting is closed" do
    let!(:meeting) do
      create(:meeting,
             :published,
             :closed,
             component:,
             address: "Carrer de la Pau 1, Barcelona",
             location: { en: "Barcelona City Hall" }, location_hints: { en: "Main entrance, 2nd floor" }, online_meeting_url: "https://meet.example.org/secret-meeting",
             closing_report: { en: "Meeting summary and conclusions" }, attendees_count: 10, closing_visible: true)
    end

    before do
      stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
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

    context "when user does not have authorization" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it "does not show minutes (closing report)" do
        expect(page).to have_no_content(translated_attribute(meeting.closing_report))
      end

      it_behaves_like "hides private info"
    end

    context "when user has authorization" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:authorization) { create(:authorization, :granted, user:, name: "csv_census", organization:) }

      before do
        login_as user, scope: :user
        visit resource_locator(meeting).path
      end

      it "shows minutes (closing report)" do
        expect(page).to have_content(translated_attribute(meeting.closing_report))
      end

      it_behaves_like "shows all info"
    end
  end
end
