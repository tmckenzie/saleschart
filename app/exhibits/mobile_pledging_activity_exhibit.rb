class MobilePledgingActivityExhibit < ActivityExhibit
  FULFILLMENT = 'fulfillment'

  def config_page_navigation
    super
    page.add_section_from(id: 'keyword', heading: 'Keyword', action: 'setup_keyword', default: true)
    if !new?
      ck = model.activity_config.campaigns_keyword

      page.add_section_from(id: 'online-forms', heading: 'Online Forms', action: 'setup_online_forms')
      page.add_section_from(id: 'donor-experience', heading: 'Mobile Experience', action: 'setup_mobile_experience')

      if ck.has_payment_forms?
        page.add_section_from(id: FULFILLMENT, heading: 'Fulfillment', action: 'setup_fulfillment')
        page.add_section_from(id: 'fundraising-thermometer', heading: 'Fundraising Thermometer', action: 'setup_fundraising_thermometer')
        page.add_section_from(id: 'givelater', heading: 'GiveLater', action: 'setup_givelater')
        page.add_section_from(id: 'givelater-buttons', heading: 'GiveLater Buttons', action: 'setup_givelater_buttons')
        page.add_section_from(id: 'offline-form', heading: 'Enter Offline Donation', action: 'offline_donations')
      end
      if ck.npo.has_qr_management_feature?
        # page.add_section_from(id: 'qr-management', heading: 'Setup QR Code', action: 'setup_qr_code')
      end

      page.add_section_from(id: SOCIAL_MEDIA_SETTINGS, heading: 'Social Media Settings')
    end
  end

  def setup_keyword
    form_remote_attr = { remote: true }
    {
      partial: "activities/setup_keyword",
      locals: {
        form_attributes: new? ? {
          as: 'activity',
          url: view.activities_path(type: 'mobile_pledging')
        } : {
          as: 'activity',
          url: view.activity_path,
          method: :put
        }.merge(form_remote_attr),
        activity_config: model.activity_config,
        keyword_extras: "activities/mobile_pledging/setup_keyword_extras",
        keyword_header: "activities/mobile_pledging/setup_keyword_header",
        existing_keywords: view.current_npo.mobile_pledging_keywords.live
      }.merge(section_locals)
    }
  end

  def setup_mobile_experience
    partial = "activities/setup_mobile_experience"
    {
      partial: partial,
      locals: {
        activity_config: model.activity_config,
        campaigns_keyword: model.activity_config.campaigns_keyword}.merge(section_locals)
    }
  end

  def setup_fulfillment
    fulfillment = ActivitySetupFulfillmentExhibit.new(model, view)
    define PAGE, partial: fulfillment, fulfillment: fulfillment
    nil
  end

  def setup_fundraising_thermometer
    ck = model.activity_config.campaigns_keyword
    is_version2 = ck.supports_graph_version_2_0? && ck.graph_version == GraphVersion::VERSION_2
    graph_src = is_version2 ? view.graph2_public_campaigns_keywords_url(anchor: "/#{ck.id}/fundraising/wall/preview")
                          : view.campaigns_keyword_graph_url(ck.encoded_id)
    {
      partial: "modularized/setup_fundraising_thermometer",
      locals: {
         graph_src: graph_src,
         full_screen_url: view.campaigns_keyword_graph_url(ck.encoded_id),
         graph_for: ck,
         goal_field: "fundraising_goal",
         update_goal: true,
         fundraising_goal: ck.fundraising_goal,
         graph_setting: ck.graph_setting,
         is_version2: is_version2
      }.merge(section_locals)
    }
  end

  def setup_givelater
    {
      partial: "activities/mobile_pledging/setup_givelater",
      locals: {
          pledging_widget_configuration: model.activity_config.campaigns_keyword.pledging_widget_configuration
      }.merge(section_locals)
    }
  end

  def setup_givelater_buttons
    {
      partial: "activities/mobile_pledging/givelater_button_configuration",
      locals: {
        widget_configuration: model.activity_config.campaigns_keyword.pledging_widget_configuration
      }.merge(section_locals)
    }
  end

  def setup_qr_code
    {
      partial: "activities/mobile_pledging/setup_qr_code",
      locals: {
        campaigns_keyword: model.activity_config.campaigns_keyword
      }.merge(section_locals)
    }
  end

  def offline_donations
    per_page = view.current_npo.keyword_pagination_count.to_i <= 0 ? 30 : view.current_npo.keyword_pagination_count.to_i
    offline_donations = campaigns_keyword.offline_transactions.order('created_at desc').paginate(page: params[:page], per_page: per_page)
    {
      partial: "activities/offline_donation",
      locals: {
        campaigns_keyword: campaigns_keyword,
        offline_donations: offline_donations
      }.merge(section_locals)
    }
  end

  protected
  def setup_components
    super
    if !new? && model.activity_config.campaigns_keyword.active?
      append NAVIGATION,
        partial: "activities/mobile_pledging/display_links",
        campaigns_keyword: model.activity_config.campaigns_keyword
    end
    skip :text_config
    skip :email_config
  end

  def setup_page_components
    define PAGE, with: current_page_section.id if block_defined?(current_page_section.id)
    super
  end

end
