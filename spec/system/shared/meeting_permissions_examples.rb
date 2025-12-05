# frozen_string_literal: true

shared_examples "shows all info" do
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

shared_examples "hides private info" do
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

shared_examples "permissions are set" do
  context "when user is not logged in" do
    before do
      visit resource_locator(meeting).path
    end

    it_behaves_like "hides private info"
  end

  context "when user is logged in but does not have authorization" do
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      login_as user, scope: :user
      visit resource_locator(meeting).path
    end

    it_behaves_like "hides private info"
  end

  context "when user has required authorization" do
    let(:user) { create(:user, :confirmed, organization:) }
    let!(:authorization) { create(:authorization, :granted, user:, name: "csv_census", organization:) }

    before do
      login_as user, scope: :user
      visit resource_locator(meeting).path
    end

    it_behaves_like "shows all info"
  end

  context "when user is admin" do
    let(:admin) { create(:user, :admin, :confirmed, organization:) }

    before do
      login_as admin, scope: :user
      visit resource_locator(meeting).path
    end

    it_behaves_like "shows all info"
  end
end
