module Navigation
  class Menu

    MENU_ICON_MAPPING = {
        'Settings' => 'icon-cog-1',
        OnlineGift::DISPLAY_NAME => 'icon-web-analytics',
        'Crowdfunding/Peer to Peer' => 'icon-crowdfunding',
        'Text to Donate' => 'icon-text-to-donate',
        'Give Later' => 'icon-give-later',
        'Landing Page' => 'icon-landing-page-1',
        'Donor Wall' => 'icon-donor-wall',
        'Thermometer' => 'icon-thermometer',
        FormType.friendly_name(FormType::TICKETING) => 'icon-ticketing',
        FormType.friendly_name(FormType::REGISTRATION_FORM_TYPE) => 'icon-registration',
        'Pledging' => 'icon-pledging',
        'Check-in' => 'icon-checkin',
        FormType.friendly_name(FormType::SPONSORSHIP) => 'icon-sell-sponsorship',
        'Charge Later' => 'icon-charge-later',
        'Auctions' => 'icon-auctions',
        FormType.friendly_name(FormType::VOLUNTEER_SIGN_UP) => 'icon-volunteer-signup',
        FormType.friendly_name(FormType::SURVEY) => 'icon-survey',
        FormType.friendly_name(FormType::PETITION) => 'icon-petition',
        FormType.friendly_name(FormType::MEMBERSHIP) => 'icon-membership',
        'SMS Subscription' => 'icon-subscription-opt-in',
        FormType.friendly_name(FormType::PAYMENT) => 'icon-goods-and-services',
        FormType.friendly_name(FormType::GENERAL) => 'icon-form-buider',
        'Message Wall' => 'icon-messagewall',
        'Dashboard' => 'icon-dash',
        'Send Email/Text' => 'icon-send-email-text',
        'Message Templates' => 'icon-schedule',
        'Manage Lists' => 'icon-manage-list',
        'Manage Contacts' => 'fa fa-users',
        'Social Sharing' => 'icon-share',
        'Edit Templates' => '',
        'Search Transactions' => 'icon-search-and-download',
        'Campaigns' => 'icon-campaigns',
        'Recurring Donations' => 'icon-recurring',
        'Web Analytics' => 'icon-web-analytics',
        'Saved Reports' => 'icon-saved',
        'Auction' => 'icon-auctions',
        'Contacts'  => 'icon-contacts'
    }

    def initialize(view_context, referrer = nil)
      @view_context = view_context
      @referrer = referrer
    end

    def self.build_nav_links(view_context, user)
      if user.mobilecause_admin?
        menu = Navigation::MCAdminMenu.new(view_context)
      elsif user.call_center_user
        menu = Navigation::CallCenterMenu.new(view_context)
      elsif user.channel_partner? || user.reseller?
        menu = Navigation::ChannelPartnerMenu.new(view_context)
      elsif user.freemium_npo?
        menu = Navigation::FreemiumNpoMenu.new(view_context)
      elsif user.npo
        menu = Navigation::NpoMenu.new(view_context)
      else
        menu = Navigation::Menu.new(view_context)
      end
      menu.generate_links(user).with_indifferent_access
    end

    def generate_links(user)
      {
        support_menu_links: generate_support_menu_links,
        account_info_links: generate_account_menu_links(user),
        settings_links: generate_settings_links(user),
        main_nav_links: generate_main_menu_links(user),
        footer_nav_links: generate_footer_links(user),

      }
    end

    def generate_support_menu_links
      links = []
      links << { label: 'Create Ticket', link: 'http://mcause.us/supportticket' }
      links << { label: 'Knowledge Center', link: 'http://mcause.us/support' }
      links << { label: 'Training Videos', link: 'http://mcause.us/trainingvideos' }
      links << { label: 'Event Kit', link: 'http://mcause.us/eventkit' }
      links << { label: 'Case Studies', link: 'http://mcause.us/supportcasestudies' }
      links << { label: 'Ebooks', link: 'http://mcause.us/supportebooks' }
      links << { label: 'Infographics', link: 'http://mcause.us/supportinfogfx' }
      links
    end

    def generate_main_menu_links(user)
      links = []
      # links << { label: 'Dashboard', link: @view_context.root_url }
      links
    end

    def generate_settings_links(user)
      links = []
    end

    def generate_footer_links(user)
      links = []
      links << { "Privacy" => "https://www.mobilecause.com/privacy", attrs: { target: '_blank' } }
      links << { "PCI" => "https://www.mobilecause.com/pci", attrs: { target: '_blank' } }
      links << { "Refund" => "https://www.mobilecause.com/refunds", attrs: { target: '_blank' } }
      links << { "Terms & Conditions" => "https://www.mobilecause.com/terms", attrs: { target: '_blank' } }
      links
    end

    def generate_account_menu_links(user)
      links = []
      links << { label: 'Profile', link: get_edit_user_url }
      links << generate_logout_link(user)
      links << { label: 'Switch Role', link: @view_context.select_role_user_path(user) } if user.dual_user?
      links << { label: 'Switch Account', link: @view_context.select_user_path(result: 'switch', email: user.email) } if user.multi_user?
      links
    end

    def generate_logout_link(user)
      { label: 'Log Out', link: @view_context.destroy_user_session_url(protocol: (Rails.env.development? ? "http" : "https")), data: { method: :delete } }
    end

    def get_edit_user_url
      @view_context.edit_user_registration_url
    end


    def reports_menu_links(user)
      links = []
      links << { label: 'Search Transactions', link: @view_context.search_path(Filter::FilterView::TRANSACTION_SEARCH), icon_class: '' }
      links << { label: 'Pledged Donations', link: @view_context.donations_path("donation_filter[keyword_type]" => nil), icon_class: '' }
      links << { label: 'Recurring Donations', link: @view_context.recurring_donations_path("donation_filter[keyword_type]" => nil), icon_class: '' }
      links << { label: 'Download Center', link: @view_context.download_requests_path, icon_class: '' }
      links
    end

    def support_menu_links
      links = []
      links << { 'Support Center' => 'http://mcause.us/support', attrs: { target: '_blank' } }
      links << { 'Training Videos' => 'http://mcause.us/trainingvideos', attrs: { target: '_blank' } }
      links << { 'Event Kit' => 'http://mcause.us/eventkit', attrs: { target: '_blank' } }
      links << { 'Case Studies' => 'http://mcause.us/supportcasestudies', attrs: { target: '_blank' } }
      links << { 'Ebooks' => 'http://mcause.us/supportebooks', attrs: { target: '_blank' } }
      links << { 'Infographics' => 'http://mcause.us/supportinfogfx', attrs: { target: '_blank' } }
      links << { 'Create Ticket' => 'http://mcause.us/supportticket', attrs: { target: '_blank' } }
      links
    end
  end

end
