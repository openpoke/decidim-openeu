# frozen_string_literal: true

require "rails_helper"

describe "Visit the home page", perform_enqueued: true do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:component) { create(:proposal_component, organization:) }

  it_behaves_like "followable space content for users" do
    let(:followable) { component }
    let(:followable_path) { Decidim::EngineRouter.main_proxy(component).root_path }
  end
end
