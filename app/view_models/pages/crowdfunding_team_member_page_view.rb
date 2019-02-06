module Pages
  class CrowdfundingTeamMemberPageView < CrowdfundingPageView
    attr_accessor :team

    delegate :banner_images,
             :display_name,
              to: :team,
              prefix: :team

    def initialize(view, page, team, team_member, page_theme: nil)
      self.team = team
      super(view, page, team_member, page_theme)
    end

    def donors_link_label
      TEAMS_LINK_DEFAULT_TEXT
    end

    def fundraiser_button_text
      page.fundraiser_button_element.link_text(use_default: false).presence || "Join My Team"
    end

    def fundraiser_button_url
      form_id = page.fundraiser_button_element.form_id
      form = form_id ? DonationFormSetting.find_by_id(form_id) : nil
      view.get_signup_path_from(peer_fundraiser, form, team)
    end

    def fundraiser_name
      view.display_fundraiser_name(peer_fundraiser)
    end
  end
end