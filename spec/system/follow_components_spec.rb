# frozen_string_literal: true

require "rails_helper"

describe "Visit a followable component" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:component) { create(:proposal_component, organization:) }
  let(:followable_path) { Decidim::EngineRouter.main_proxy(component).root_path }

  it_behaves_like "followable space content for users" do
    let(:followable) { component }
  end

  context "when following a component with a proposal" do
    let!(:proposal) { create(:proposal, component:) }
    let(:follower_user) { create(:user, :confirmed, organization:, notifications_sending_frequency: "real_time") }
    let(:last_follow) { Decidim::Follow.last }
    let(:proposal_path) { Decidim::EngineRouter.main_proxy(component).proposal_path(proposal) }
    let!(:follow) { create(:follow, user: follower_user, followable: component) }

    before do
      switch_to_host(organization.host)
    end

    it "a new comment notifies the followers of the component" do
      # Create a notification for the follower
      comment = create(:comment, commentable: proposal, author: user)
      perform_enqueued_jobs do
        Decidim::Comments::NewCommentNotificationCreator.new(comment, []).create
      end
      login_as follower_user, scope: :user
      visit decidim.account_path
      expect(page).to have_field("Your email", with: follower_user.email)
      visit decidim.notifications_path

      expect(page).to have_content("There is a new comment from #{user.name}")
    end
  end
end
