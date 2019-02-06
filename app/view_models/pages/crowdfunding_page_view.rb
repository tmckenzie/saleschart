module Pages
  class CrowdfundingPageView < PageView
    attr_reader :peer_fundraiser

    delegate :progress_bar_element,
             :carousel_element,
             :total_raised_element,
             :card_display_style,
             :card_background_color,
              to: :page

    delegate :label,
      to: :total_raised_element,
      prefix: :total_raised

    delegate :color,
             :animated?,
              to: :progress_bar_element,
              prefix: :progress_bar

    delegate :quantity_sold_goal_type?, to: :campaigns_keyword

    DONORS_LINK_DEFAULT_TEXT = "See Who Has Donated"
    TEAMS_LINK_DEFAULT_TEXT = "View Supporters"

    def initialize(view, page, peer_fundraiser, page_theme = nil)
      @peer_fundraiser = peer_fundraiser
      super(view, page, page_theme)
    end

    def campaigns_keyword
      @campaigns_keyword ||= page.originable
    end

    def profile_image
      banner_personal_image_url
    end

    def profile_type
      "Fundraiser"
    end

    def profile_name
      view.display_fundraiser_name(peer_fundraiser)
    end

    def banner_personal_image_url
      peer_fundraiser.canonical_personal_img_file_name.present? ?
          peer_fundraiser.canonical_personal_img_url : banner_celebrity_image_url
    end

    def banner_celebrity_image_url
      image_url(page.banner_celebrity_image_element)
    end

    def show_organization_logo?
      page.organization_logo_element.image.present?
    end

    def hide_progress_bar?
      display_element = campaigns_keyword.has_fundraising_goal? && progress_bar_element.display?
      theme_hide = !display_element && (if theme == Theme::ORIGINAL
        !progress_bar_element.show_donors_link?
      else
        true
      end)

      (campaigns_keyword.default_form.nonpayment_type? && !quantity_sold_goal_type?) ||
      theme_hide
    end

    def display_donors?
      progress_bar_element.show_donors_link?
    end

    def show_progress_bar_goal?
      progress_bar_element.show_goal?
    end

    def donors_link_label
      if progress_bar_element.donors_link_text.present?
        progress_bar_element.donors_link_text
      elsif root_fundraiser?
        details_link_label = TEAMS_LINK_DEFAULT_TEXT
      else
        details_link_label = DONORS_LINK_DEFAULT_TEXT
      end
    end

    def donors_link_url
      if root_fundraiser?
        view.teams_public_peer_fundraiser_url(peer_fundraiser)
      else
        details_link_url = root_fundraiser? ?
            view.fundraisers_public_peer_fundraiser_url(peer_fundraiser) :
            view.donors_public_peer_fundraiser_url(peer_fundraiser)
      end
    end

    def main_text_html
      StringUtil.text_to_html(@peer_fundraiser.call_to_action.presence || main_text, true)
    end

    def share_button_url
      view.share_public_peer_fundraiser_url(peer_fundraiser)
    end

    def share_link_url
      view.peer_fundraising_home_page_url(peer_fundraiser)
    end

    def share_link_label
      "Your Fundraiser Page Link:"
    end

    def donate_button_text
      page.donate_button_element.link_text.presence || (campaigns_keyword.default_form.nonpayment_type? ?
          PeerFundraiserSetting::DEFAULT_MEMBERSHIP_FORM_BUTTON_TEXT : PeerFundraiserSetting::DEFAULT_FORM_BUTTON_TEXT)
    end

    def open_page_buttons_in_lightbox
      page.open_page_buttons_in_lightbox ? page.open_page_buttons_in_lightbox : SharedSettingType::OPEN_PAGE_BUTTONS_IN_LIGHTBOX
    end

    def donate_button_url
      view.get_donation_path_from(peer_fundraiser, page.form_linked_to_donate_button_element)
    end

    def fundraiser_button_text
      page.fundraiser_button_element.link_text
    end

    def edit_page_url
      view.edit_volunteer_peer_fundraiser_path(peer_fundraiser)
    end

    def edit_page_link_options
      link_text = CrowdfundingPage::IS_THIS_YOUR_PAGE_LINK_TEXT
      link_method = :get
      if view.current_peer_fundraiser
        link_text = "Edit My Page"
        link_url = edit_page_url
      else
        link_text = page.login_button_element.link_text if page.login_button_element.try(:link_text)
        if campaigns_keyword.aha?
          link_url = "https://www.kintera.org/faf/login/loginParticipant.asp?login=lmenu&ievent=#{campaigns_keyword.alternate_id}&lis=1"
        elsif peer_fundraiser.needs_to_set_password
          link_url = view.public_peer_fundraiser_registration_confirm_registration_path(peer_fundraiser.registration)
          link_method = :put
        else
          link_url = view.login_public_peer_fundraiser_path(peer_fundraiser, login: peer_fundraiser.try(:user).try(:username))
        end
      end
      { link_text: link_text, link_url: link_url, link_method: link_method }
    end

    def fundraiser_button_url
      form_id = page.fundraiser_button_element.form_id
      form = form_id ? DonationFormSetting.find_by_id(form_id) : nil
      view.get_signup_path_from(peer_fundraiser, form)
    end

    def banner_background_image_url
      image_url(page.banner_background_image_element)
    end

    def banner_logo_image_url
      image_url(page.banner_logo_element)
    end

    def main_text
      @main_text ||= (page.main_text_element.display ? page.main_text_element.content : '')
    end

    def facebook_share_title
      campaigns_keyword.npo.name
    end

    def facebook_share_description
      msg = page.facebook_message_element.content
      root_page_url = view.peer_fundraising_home_page_url(campaigns_keyword.root_fundraiser)
      msg.try(:gsub, root_page_url, share_link_url)
    end

    def facebook_share_image
      page.facebook_message_element.image
    end

    def show_submit_for_review_button?
      peer_fundraiser.status == PeerFundraiserStatus.pending.id && view.current_user == peer_fundraiser.user
    end

    def fundraiser_avatar
      peer_fundraiser.avatar_img
    end

    def fundraising_total
      if peer_fundraiser.root_fundraiser?
        campaigns_keyword.total_collected_or_quantity_sold
      else
        peer_fundraiser.total_collected_or_quantity_sold
      end
    end

    def donor_count
      if peer_fundraiser.root_fundraiser?
        campaigns_keyword.donor_count
      else
        peer_fundraiser.donor_count
      end
    end

    def fundraising_goal
      peer_fundraiser.display_fundraising_goal
    end

    def fundraising_progress
      view.collected_percentage(fundraising_total, fundraising_goal)
    end

    def fundraising_progress_for(team)
      view.collected_percentage(team.display_team_fundraising_total, team.display_team_fundraising_goal)
    end

    def home_page_url
      view.fundraising_url_with_email_host(peer_fundraiser)
    end
    alias_method :facebook_share_url, :home_page_url

    def donors
      donors = if root_fundraiser?
        campaigns_keyword.collected_fundraising_donations
      else
        peer_fundraiser.collected_fundraising_donations
      end

      if theme == Theme::ORIGINAL
        donors = donors.paginate(:page => view.params[:page], :per_page => (view.params[:per_page] || 30))
      end
      donors
    end

    def root_fundraiser?
      peer_fundraiser.root_fundraiser?
    end

    def teams_url
      view.teams_public_peer_fundraiser_url(peer_fundraiser)
    end

    def fundraisers_label
      "Fundraisers"
    end

    def fundraisers_url
      view.fundraisers_public_peer_fundraiser_url(peer_fundraiser)
    end

    def donors_url
      view.donors_public_peer_fundraiser_url(peer_fundraiser)
    end

    def team_page?
      false
    end

    def fundraisers
      PeerFundraiserService.new.filter_and_sort_fundraisers(
        peer_fundraiser, search_for_name: search_for, order_by: sort_by, order: order)
    end

    def teams
      teams = TeamService.new.list_teams(campaigns_keyword, search_for_name: search_for,
                                         order_by: sort_by, order: order)
      teams = teams.paginate(pagination_options)
      teams
    end

    def show_banner_background_image?
      page.banner_background_image_element.try(:display?) &&
      page.banner_background_image_element.image.present?
    end

    def show_banner_logo?
      page.banner_logo_element.try(:display?)
    end

    def show_banner_celebrity_image?
      !peer_fundraiser.root_fundraiser? ||
       (page.banner_celebrity_image_element.try(:display?) &&
        page.banner_celebrity_image_element.try(:image).present?)
    end

    def show_banner_images?
      show_banner_celebrity_image? || show_banner_logo?
    end

    def show_personalization_banner?
      !peer_fundraiser.root_fundraiser? && page.display_personalization_banner
    end

    def remote_path_for(section_name, options={})
      options = options.merge(theme: theme, format: :js)

      case section_name
        when PageSection::DONORS_SECTION
          view.donors_public_peer_fundraiser_path(peer_fundraiser, options)
        when PageSection::FUNDRAISERS_SECTION
          view.fundraisers_public_peer_fundraiser_path(peer_fundraiser, options)
        when PageSection::TEAMS_SECTION
          view.teams_public_peer_fundraiser_path(peer_fundraiser, options)
        when PageSection::STATISTICS_SECTION
          view.statistics_public_peer_fundraiser_path(peer_fundraiser, options)
      end
    end

    def banner_text
      if root_fundraiser?
        page.banner_text_element.content
      else
        page.banner_text_element.default_content.call(page).gsub(page.originable.keyword_string, peer_fundraiser.personal_keyword)
      end
    end

    def fundraisers_sort_links
      if quantity_sold_goal_type?
        links =  [{
          link: fundraisers_sort_link('Largest Quantity Sold', PeerFundraiserService::ORDER_BY_QUANTITY_SOLD),
          sort_by: PeerFundraiserService::ORDER_BY_QUANTITY_SOLD
        }]
      else
        links =  [{
          link: fundraisers_sort_link('Highest Donations', PeerFundraiserService::ORDER_BY_TOTAL),
          sort_by: PeerFundraiserService::ORDER_BY_TOTAL
        }]
      end

      links += [
        {
          link: fundraisers_sort_link('Name', PeerFundraiserService::ORDER_BY_NAME),
          sort_by: PeerFundraiserService::ORDER_BY_NAME,
          default: true
        },
        {
          link: fundraisers_sort_link('Highest Goal', PeerFundraiserService::ORDER_BY_GOAL),
          sort_by: PeerFundraiserService::ORDER_BY_GOAL
        },
        {
          link: fundraisers_sort_link('Most Members', PeerFundraiserService::ORDER_BY_MOST_TEAM_MEMBERS),
          sort_by: PeerFundraiserService::ORDER_BY_MOST_TEAM_MEMBERS
        }
      ]
    end

    def fundraisers_sort_link(title, sort_by)
      view.link_to title, remote_path_for(PageSection::FUNDRAISERS_SECTION, sort_by: sort_by), remote: true
    end

    def notice
      pfs = PeerFundraiserStatus.find(peer_fundraiser.status)
      if pfs.name == PeerFundraiserStatus::PENDING_STATUS
        link = view.link_to "SUBMIT FOR REVIEW", view.submit_for_review_volunteer_peer_fundraiser_path(peer_fundraiser), method: :put
        "Your page is not yet live. Please configure and save your page, then #{link}."
      else
        pfs.notice
      end
    end

    def tab_selected?(tab_name, index)
      if peer_fundraiser.root_fundraiser?
        selected_tab = page.default_selected_tab
        if selected_tab.present? && show_section?(selected_tab)
          selected_tab == tab_name
        else
          index == 0
        end
      else
        index == 0
      end
    end

    def carousel_items
      carousel_element.option_for(:carousel).items
    end

    def status
      {
        progress: {
          percent: fundraising_progress.to_i,
          color: progress_bar_color,
          animated: progress_bar_animated?
        },
        carousel: {
          items: carousel_items,
          wrap: carousel_element.wrap,
          autoscroll: carousel_element.autoscroll,
          autoscroll_interval: carousel_element.autoscroll_interval,
          autoplay: carousel_element.autoplay?,
          audio: carousel_element.autoplay_with_audio?,
          sticky_video: carousel_element.sticky_video?,
          id: carousel_element.id
        },
        donor_count: donor_count,
        fundraiser_count: fundraisers.count,
        total_raised: fundraising_total
      }
    end

    def total_raised_currency
      if quantity_sold_goal_type?
        ""
      else
        "$"
      end
    end

    def activity_object
      if peer_fundraiser.root_fundraiser?
        [campaigns_keyword.class.name, campaigns_keyword.id]
      else
        [peer_fundraiser.class.name, peer_fundraiser.id]
      end
    end

    def vue_activity_object
      type, id = activity_object

      {
        "object-type" => type,
        ":object-id" => id
      }
    end
  end
end
