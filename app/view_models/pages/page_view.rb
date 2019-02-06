module Pages
  class PageView

    attr_accessor :page_elements_by_section, :theme, :page,
                  :campaigns_keyword, :view, :page_layout

    def initialize(view, page, theme = nil)
      @view = view
      @page = page
      @theme = theme || page.theme
      @campaigns_keyword = page.originable
      @page_layout = Pages::PageLayoutView.new(page, theme: theme, page_view: self)
    end

    delegate :page_sections,
             :page_elements,
             :page_section_mappings,
             :page_section_names,
             :build_page_sections,
             to: :page_layout

    delegate :jargon_for_team, :background_image_overlay_color, to: :page
    delegate :account, to: :page
    delegate :has_feature?, to: :account
    delegate :params, to: :view

    [:order, :sort_by, :search_for, :per_page].each do |option|
      define_method option do
        view.params[option]
      end
    end

    def current_page
      view.params[:page]
    end

    def pagination_options
      {
        :page => current_page,
        :per_page => per_page || 30
      }
    end

    def lighten_color(color, percent=15)
      Sass::Script::Parser.parse("lighten(#{color}, #{percent})", 0, 0).perform(Sass::Environment.new)
    rescue
      color
    end

    def darken_color(color, percent=15)
      Sass::Script::Parser.parse("darken(#{color}, #{percent})", 0, 0).perform(Sass::Environment.new)
    rescue
      color
    end

    def account_name
      page.account.accountable.name
    end

    def account_terms_url
      page.account.accountable.terms_url
    end

    def npo_id
      a = page.account
      if a.accountable_type == Npo.name
        a.accountable_id
      end
    end

    def bg_image_css
      if page.display_background && (img = page.background_image).present?
        "background: url('#{img.url}');"
      end
    end

    def bg_image_orientation_css
      case page.background_orientation
        when DonationFormSetting::BG_ORIENTATION_CENTER
          "background-size: cover; background-attachment: fixed; background-repeat: no-repeat;"
        when DonationFormSetting::BG_ORIENTATION_TILE_HORZ
          "background-repeat: repeat-x;"
        when DonationFormSetting::BG_ORIENTATION_TILE
          "background-repeat: repeat;"
      end
    end

    def bg_color_css
      default_background_color = if page.theme == Theme::ORIGINAL
        '#C2C2C2'
      else
        '#FFFFFF'
      end
      "background-color: #{page.background_color || default_background_color}"
    end

    def primary_color
      page.brand_color
    end

    def lightened_primary_color(percent=15)
      lighten_color(primary_color, percent)
    end

    def darkened_primary_color(percent=15)
      darken_color(primary_color, percent)
    end

    def secondary_color
      page.secondary_color
    end

    def image_url(img_element)
      img = img_element.image
      if img.respond_to?(:custom_image)
        img = img.try(:custom_image)
        if img.try(:styles).try(:key?, :large)
          img.url(:large)
        else
          img.try(:url)
        end
      elsif img.respond_to?(:url)
        img.styles.try(:key?, :large) ? img.url(:large) : img.url
      else
        ""
      end
    end

    def show_section?(section_name)
      page_section_mappings[section_name].present?
    end

    def show_element?(element)
      method_postfix = element.internal_name.gsub(" ", "_").underscore
      show_element_method = "show_#{method_postfix}?"
      hide_element_method = "hide_#{method_postfix}?"

      if respond_to?(show_element_method)
        send(show_element_method)
      elsif respond_to?(hide_element_method)
        !send(hide_element_method)
      else
        if !element.is_a?(Elements::BaseElement)
          element = page.theme_element_for(element.internal_name)
        end
        element.try(:display?)
      end
    end

    def donate_url_for(object)
      case object
      when PeerFundraiserTeam
        view.get_donation_path_from(object.team_captain_peer_fundraiser,
                                    object.campaigns_keyword.crowdfunding_page.try(:form_linked_to_donate_button_element),
                                    object)
      end
    end

    def join_url_for(object)
      case object
      when PeerFundraiserTeam
        view.get_signup_path_from(object.team_captain_peer_fundraiser,
                                  object.campaigns_keyword.crowdfunding_page.try(:form_linked_to_fundraiser_button_element),
                                  object)
      end
    end

    def root_url_for(object)
      case object
      when PeerFundraiserTeam
        view.volunteer_fundraiser_teams_link_url(object.campaigns_keyword.shortcode.url_node.to_s, object.campaigns_keyword.keyword_string, object.name)
      end
    end

    def progress_for(object)
      view.collected_percentage(total_raised_for(object), goal_for(object))
    end

    def total_raised_for(object)
      case object
      when PeerFundraiserTeam
        object.display_team_fundraising_total
      end
    end

    def goal_for(object)
      case object
      when PeerFundraiserTeam
        object.display_team_fundraising_goal
      end
    end

    def logout_url
      view.destroy_user_session_url(protocol: view.protocol, redirect_url: URI.escape(view.request.path))
    end

    def login_url
      view.new_user_session_url(protocol: view.protocol, redirect_url: URI.escape(view.request.path))
    end

    def show_card_subtitle?
      true
    end

    def profile_picture_type
      type = page.profile_picture_type
      if ['rounded', 'circle', 'thumbnail'].include?(type)
        type
      else
        'circle'
      end
    end

  end
end