# frozen_string_literal: true

module MeetingsControllerOverride
  extend ActiveSupport::Concern

  included do
    include MeetingPrivateDataHelper

    def tab_panel_items
      items = [
        {
          enabled: meeting.public_participants.any?,
          id: "participants",
          text: t("attending_participants", scope: "decidim.meetings.public_participants_list"),
          icon: "group-line",
          method: :cell,
          args: ["decidim/meetings/public_participants_list", meeting]
        },
        {
          enabled: !meeting.closed? && meeting.user_group_registrations.any?,
          id: "organizations",
          text: t("attending_organizations", scope: "decidim.meetings.public_participants_list"),
          icon: "community-line",
          method: :cell,
          args: ["decidim/meetings/attending_organizations_list", meeting]
        },
        {
          enabled: meeting.linked_resources(:proposals, "proposals_from_meeting").present?,
          id: "included_proposals",
          text: t("decidim/proposals/proposal", scope: "activerecord.models", count: 2),
          icon: resource_type_icon_key("Decidim::Proposals::Proposal"),
          method: :cell,
          args: ["decidim/linked_resources_for", meeting, { type: :proposals, link_name: "proposals_from_meeting" }]
        },
        {
          enabled: meeting.linked_resources(:results, "meetings_through_proposals").present?,
          id: "included_meetings",
          text: t("decidim/accountability/result", scope: "activerecord.models", count: 2),
          icon: resource_type_icon_key("Decidim::Accountability::Result"),
          method: :cell,
          args: ["decidim/linked_resources_for", meeting, { type: :results, link_name: "meetings_through_proposals" }]
        }
      ]

      items += attachments_tab_panel_items(@meeting) if private_data_allowed?(@meeting)

      @tab_panel_items ||= items
    end
  end
end
