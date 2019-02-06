module Pages
  class CrowdfundingTeamPageView < CrowdfundingPageView
    attr_reader :team, :referred_by_team_member

    def initialize(view, page, team, referred_by_team_member: false, page_theme: nil, peer_fundraiser: team.team_captain_peer_fundraiser)
      @team = team
      @referred_by_team_member = referred_by_team_member
      super(view, page, peer_fundraiser, page_theme)
    end

    delegate :banner_images,
             :display_name,
              to: :team,
              prefix: :team

    def team_service
      @team_service ||= TeamService.new
    end

    def fundraising_total
      team.total_collected_or_quantity_sold
    end

    def fundraising_goal
      team.display_team_fundraising_goal
    end

    def donors_link_label
      "See Team Members"
    end

    def profile_image
      team.team_logo
    end

    def profile_type
      page.jargon_for_team
    end

    def profile_name
      team_display_name
    end

    def donors_link_url
      view.team_members_public_peer_fundraiser_team_url(team)
    end

    def share_button_url
      view.share_public_peer_fundraiser_team_url(team)
    end

    def home_page_url
      if referred_by_team_member
        super
      else
        view.peer_fundraising_home_team_page_url(team)
      end
    end

    def open_page_buttons_in_lightbox
      page.open_page_buttons_in_lightbox ? page.open_page_buttons_in_lightbox : SharedSettingType::OPEN_PAGE_BUTTONS_IN_LIGHTBOX
    end

    def donate_button_url
      view.get_donation_path_from(peer_fundraiser, page.form_linked_to_donate_button_element, team)
    end

    def show_fundraiser_button?
      allow_team_participation = peer_fundraiser.
        campaigns_keyword.
        support_team_participation?
      member_of_team = view.member_of_team?(peer_fundraiser, team)

      allow_team_participation && !member_of_team
    end

    def fundraiser_button_url
      form_id = page.fundraiser_button_element.form_id
      form = form_id ? DonationFormSetting.find_by_id(form_id) : nil
      view.get_signup_path_from(peer_fundraiser, form, team)
    end

    def fundraiser_button_text
      page.fundraiser_button_element.team_link_text
    end

    def share_link_url
      view.peer_fundraising_home_team_page_url(team)
    end

    def share_link_label
      "Link to Team Page"
    end

    def donor_count
      team.donor_count
    end

    def donors
      donors = team.collected_fundraising_donations
      if theme == Theme::ORIGINAL
        donors = donors.paginate(:page => view.params[:page], :per_page => (view.params[:per_page] || 30))
      end
      donors
    end

    def fundraisers_label
      "Members"
    end

    def fundraisers_url
      view.team_members_public_peer_fundraiser_team_url(team)
    end

    def donors_url
      view.donors_public_peer_fundraiser_team_url(team)
    end

    def team_page?
      true
    end

    def fundraisers
      team_service.list_members(team, order_by: sort_by, search_for_name: search_for)
    end

    def fundraiser_name
      ""
    end

    def banner_personal_image_url
      team.team_logo.present? ? team.team_logo : super
    end

    def remote_path_for(section_name, options={})
      options = options.merge(theme: theme, format: :js)
      case section_name
        when PageSection::DONORS_SECTION
          view.donors_public_peer_fundraiser_team_path(team, options)
        when PageSection::FUNDRAISERS_SECTION
          view.team_members_public_peer_fundraiser_team_path(team, options)
        when PageSection::STATISTICS_SECTION
          view.statistics_public_peer_fundraiser_team_path(team, options)
      end
    end

    def edit_page_url
      view.edit_volunteer_peer_fundraiser_team_path(peer_fundraiser.peer_fundraiser_team, reset_current_pf: true)
    end

    def fundraisers_sort_links
      super.reject {|l| l[:sort_by] == PeerFundraiserService::ORDER_BY_MOST_TEAM_MEMBERS }
    end

    def activity_object
      [team.class.name, team.id]
    end
  end
end