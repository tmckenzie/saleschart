module Navigation
  class NpoMenu < Menu
    def generate_logout_link(user)
      data_attr = { method: :delete }
      if user.npo.has_main_dashboard_analytics_feature?
        data_attr[:sisense_logout] = Sisense.url
      end
      { label: 'Log Out', link: @view_context.destroy_user_session_url(protocol: (Rails.env.development? ? "http" : "https")), data: data_attr }
    end

    def generate_settings_links(user)
      links = super
      links << { label: 'Settings', link: @view_context.account_url, icon_class: "mc #{MENU_ICON_MAPPING['Settings']}" } if user.vendor_admin?
      #links << {"3rd Party Credit Card Setup" => '#'}
      #links << {"CRM Connectors" => '#'}
      links
    end

    def generate_main_menu_links(user)
      links = []
      links << { label: 'Fundraising', submenu: setup_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Events', submenu: event_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Engagement', submenu: engagement_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Communication & Marketing', submenu: communications_and_marketing_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Reporting', submenu: reports_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      # links << { label: 'Merchant Services', submenu: merchant_center_links(user) }
      # links << { label: 'et Help', link: support_menu_links }
      links
    end

    def generate_support_menu_links
      links = []
      links << { label: 'Contact Support', link: 'http://mcause.us/supportticket', target: '_blank' }
      links << { label: 'Knowledge Center', link: 'http://mcause.us/support', target: '_blank' }
      links << { label: 'Training Videos', link: 'http://mcause.us/trainingvideos', target: '_blank' }
      links << { label: 'In-App Guides', link: '#', onclick: 'inline_manual_player.showPanel()' }
      links << { label: 'Digital Marketing Services', link: 'http://www.mobilecause.com/digital-marketing', target: '_blank' }
      links << { label: 'Event Kit', link: 'http://mcause.us/eventkit', target: '_blank' }
      links << { label: 'API Documentation', link: @view_context.developer_v2_documentation_index_path }
      links
    end

    def setup_menu_links(user)
      links = []
      links << { label: FormType.friendly_name(FormType::DONATION_FORM_TYPE), link: @view_context.donation_form_settings_path(form_type: FormType::DONATION_FORM_TYPE), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::DONATION_FORM_TYPE)]}", show_on_activity_modal: true }
      links << { label: 'Crowdfunding/Peer to Peer', link: @view_context.activities_path(type: 'social_giving'), link_for_new: @view_context.new_activity_path(type: 'social_giving', referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING['Crowdfunding/Peer to Peer']}", show_on_activity_modal: true }.merge!(feature_link_attributes(Feature::CROWDFUNDING, user))
      links << { label: OnlineGift::DISPLAY_NAME, link: @view_context.edit_online_gift_url, icon_class: "mc #{MENU_ICON_MAPPING['Website Donation Form']}" } if @view_context.can?(:update, OnlineGift)
      links << { label: 'Give Later', link: @view_context.widgets_activities_path, icon_class: "mc #{MENU_ICON_MAPPING['Give Later']}" }
      links << { label: 'Landing Page', link: @view_context.edit_home_page_account_path, icon_class: "mc #{MENU_ICON_MAPPING['Landing Page']}" }.merge!(feature_link_attributes(Feature::MANAGE_ACCOUNT_PAGE, user))
      # links << { label: 'Donor Wall', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Donor Wall']}" }
      links
    end

    def event_links(user)
      links = []
      links << { label: 'Thermometer', link: @view_context.graph_settings_path, icon_class: "mc #{MENU_ICON_MAPPING['Thermometer']}" }
      links << { label: 'Auction', link: @view_context.activities_path(type: 'auction'), link_for_new: @view_context.new_activity_path(type: 'auction', referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING['Auction']}", show_on_activity_modal: true }.merge!(feature_link_attributes(Feature::AUCTION_EVENT, user))
      links << { label: FormType.friendly_name(FormType::TICKETING), link: @view_context.donation_form_settings_path(form_type: FormType::TICKETING), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::TICKETING, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::TICKETING)]}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::REGISTRATION_FORM_TYPE), link: @view_context.donation_form_settings_path(form_type: FormType::REGISTRATION_FORM_TYPE), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::REGISTRATION_FORM_TYPE, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::REGISTRATION_FORM_TYPE)]}", show_on_activity_modal: true }
      links << { label: 'Check-in/Bill Later', link: @view_context.charge_later_transactions_path("transaction_filter[keyword_type]" => nil), icon_class: "mc #{MENU_ICON_MAPPING['Check-in']}" }.merge!(feature_link_attributes(Feature::DONATION_FORM_CHARGE_LATER, user))
      links << { label: FormType.friendly_name(FormType::SPONSORSHIP), link: @view_context.donation_form_settings_path(form_type: FormType::SPONSORSHIP), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::SPONSORSHIP, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::SPONSORSHIP)]}", show_on_activity_modal: true }
      # links << { label: 'Charge Later', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Charge Later']}" }
      links
    end

    def engagement_links(user)
      links = []
      links << { label: FormType.friendly_name(FormType::VOLUNTEER_SIGN_UP), link: @view_context.donation_form_settings_path(form_type: FormType::VOLUNTEER_SIGN_UP), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::VOLUNTEER_SIGN_UP, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::VOLUNTEER_SIGN_UP)]}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::SURVEY), link: @view_context.donation_form_settings_path(form_type: FormType::SURVEY), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::SURVEY, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::SURVEY)]}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::PETITION), link: @view_context.donation_form_settings_path(form_type: FormType::PETITION), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::PETITION, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::PETITION)]}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::MEMBERSHIP), link: @view_context.donation_form_settings_path(form_type: FormType::MEMBERSHIP), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::MEMBERSHIP, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::MEMBERSHIP)]}", show_on_activity_modal: true }
      links << { label: 'SMS Subscription', link: @view_context.activities_path(type: 'mobile_messaging'), link_for_new: @view_context.new_activity_path(type: 'mobile_messaging', referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING['SMS Subscription']}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::PAYMENT), link: @view_context.donation_form_settings_path(form_type: FormType::PAYMENT), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::PAYMENT, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::PAYMENT)]}", show_on_activity_modal: true }
      links << { label: FormType.friendly_name(FormType::GENERAL), link: @view_context.donation_form_settings_path(form_type: FormType::GENERAL), link_for_new: @view_context.new_activity_path(type: 'mobile_pledging', form_type: FormType::GENERAL, referrer: @referrer), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::GENERAL)]}", show_on_activity_modal: true }
      # links << { label: 'Message Wall', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Message Wall']}" }
      links
    end

    def communications_and_marketing_menu_links(user)
      links = []
      # links << { label: 'Dashboard', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Dashboard']}" }
      links << { label: 'Messages', link: @view_context.new_message_path, icon_class: "mc #{MENU_ICON_MAPPING['Send Email/Text']}" }
      links << { label: 'Create Segment', link: @view_context.search_path(Filter::FilterView::PEOPLE_SEARCH), icon_class: "mc #{MENU_ICON_MAPPING['Contacts']}" }.merge!(feature_link_attributes(Feature::ALLOW_PEOPLE_SEARCH, user))
      links << { label: 'Manage Lists', link: @view_context.constituent_lists_path, icon_class: "mc #{MENU_ICON_MAPPING['Manage Lists']}" }
      # links << { label: 'Manage Contacts', link: @view_context.npos_constituents_path, icon_class: "mc #{MENU_ICON_MAPPING['Manage Contacts']}" }
      links << { label: 'Message Templates', link: @view_context.pick_a_template_messages_path, icon_class: "mc #{MENU_ICON_MAPPING['Message Templates']}" }
      # links << { label: 'Social Sharing', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Social Sharing']}" }
      # links << { label: 'Edit Templates', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Edit Templates']}" }
      links
    end

    def support_menu_links
      links = []
      #links << { 'Search' => '#' }
      links << { 'Contact Support' => 'http://mcause.us/supportticket', attrs: { target: '_blank' } }
      links << { 'Knowledge Center' => 'http://mcause.us/support', attrs: { target: '_blank' } }
      links << { 'Training Videos' => 'http://mcause.us/trainingvideos', attrs: { target: '_blank' } }
      links << { 'In-App Guides' => '#', attrs: { onclick: 'inline_manual_player.showPanel()' } }
      links << { 'Digital Marketing Services' => 'http://www.mobilecause.com/digital-marketing', attrs: { target: '_blank' } }
      links << { 'Event Kit' => 'http://mcause.us/eventkit', attrs: { target: '_blank' } }
      links << { 'API Documentation' => @view_context.developer_dashboard_path }
      links
    end

    def reports_menu_links(user)
      links = []
      # links << { label: 'Dashboard', link: '#', icon_class: "mc #{MENU_ICON_MAPPING['Dashboard']}" }
      links << { label: 'Search Transactions', link: @view_context.search_path(Filter::FilterView::TRANSACTION_SEARCH), icon_class: "mc #{MENU_ICON_MAPPING['Search Transactions']}" }
      links << { label: 'Manage Pledges', link: @view_context.donations_path("donation_filter[keyword_type]" => nil), icon_class: "mc #{MENU_ICON_MAPPING['Pledging']}" }
      links << { label: 'Campaigns', link: @view_context.campaigns_url, icon_class: "mc #{MENU_ICON_MAPPING['Campaigns']}" } if @view_context.can?(:manage, Campaign)
      links << { label: 'Recurring Donations', link: @view_context.recurring_donations_path("donation_filter[keyword_type]" => nil), icon_class: "mc #{MENU_ICON_MAPPING['Recurring Donations']}" }
      if user.vendor.has_feature?(Feature::DONOR_REGISTRATION)
        links << { label: 'Registered Donations', link: @view_context.donor_registration_donations_path("donation_filter[keyword_type]" => nil), icon_class: "mc #{MENU_ICON_MAPPING[FormType.friendly_name(FormType::REGISTRATION_FORM_TYPE)]}" }
      end
      if user.vendor_admin? && user.npo.has_form_metrics_feature?
        links << { label: 'Web Analytics', link: @view_context.metrics_login_form_metrics_analytics_path, icon_class: "mc #{MENU_ICON_MAPPING['Web Analytics']}" }
      end
      links << { label: 'Download Center', link: @view_context.download_requests_path, icon_class: 'mc icon-saved' }
      links << { label: 'Manage Custom Fields', link: @view_context.npos_custom_fields_path, icon_class: 'mc fa fa-pencil' } if @view_context.mc_admin?
      links << { label: 'Insights', link: @view_context.analytics_dashboard_index_path, icon_class: "mc #{MENU_ICON_MAPPING['Web Analytics']}" }.merge!(feature_link_attributes(Feature::INSIGHT_DASHBOARD_ANALYTICS, user))
      links
    end

    def merchant_center_links(user)
      links = []
      links << { label: 'Dashboard', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Transaction Search', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Refund/Void', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Monthly Statements', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Card Swiper', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Download Swiper App', link: '#', icon_class: 'mc icon-' }
      links << { label: 'PayPal', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Web', link: '#', icon_class: 'mc icon-' }
      links << { label: 'Web', link: '#', icon_class: 'mc icon-' }
      links
    end

    def messages_menu_links(user)
      links = []
      links << { "Send a Text Message" => @view_context.new_message_path }
      links << { "Send an Email Message" => '#' } if user.npo.can_email?
      links << { "Schedule a Text Series" => @view_context.pick_a_template_messages_path }
      links << { "Scheduled" => @view_context.messages_url }
      links << { "Outbox" => @view_context.messages_url(type: Message::SENT) }
      links << { "Inbox" => @view_context.messages_report_index_path }
      links
    end

    def activity_modal_links_for(user, label)
      links = generate_main_menu_links(user).detect { |main_nav_link| main_nav_link[:label] == label }.try(:[], :submenu) || []
      links.select { |link| link[:show_on_activity_modal] }
    end

    def self.keyword_title_from(keyword_type)
      case keyword_type
        when 'social_giving'
          'Crowdfunding/Peer to Peer'
        when 'mobile_messaging'
          'SMS Subscription'
        when 'auction'
          'Auction'
        else
          'Text to Donate'
      end
    end

    private

    def feature_link_attributes(feature_name, user)
      if !user.vendor.has_feature?(feature_name)
        feature = Feature.from_name(feature_name)
        marketing_link = feature[:external_src]
        case feature[:disabled_display_option]
          when Feature::DisabledDisplayOption::NEW_TAB
            { link: marketing_link, target: '_blank' }
          when Feature::DisabledDisplayOption::MODAL
            { external_modal: 'true', link: marketing_link, target: "#marketing_modal" }
          when Feature::DisabledDisplayOption::DISABLED
            { disabled: 'disabled' }
          when Feature::DisabledDisplayOption::HIDDEN
            { link_class: 'hide' }
        end
      else
        {}
      end
    end
  end
end
