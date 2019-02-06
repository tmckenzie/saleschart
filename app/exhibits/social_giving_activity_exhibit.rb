class SocialGivingActivityExhibit < ActivityExhibit
  def config_page_navigation
    super
    @page.add_section_from(id: 'keyword', heading: 'Keyword', action: 'setup_keyword', default: true)
    unless new?
      @page.add_section_from(id: 'images', heading: 'Images', action: 'setup_images')
      @page.add_section_from(id: 'mobile-web', heading: 'Mobile Web', action: 'setup_mobile_web')
      @page.add_section_from(id: 'fundraising-thermometer', heading: 'Fundraising Thermometer', action: 'setup_fundraising_thermometer')
      if model.activity_config.campaigns_keyword.campaign.npo.has_qr_management_feature?
        # @page.add_section_from(id: 'qr-management', heading: 'Setup QR Code', action: 'setup_qr_code')
      end
    end
  end

  def setup_keyword
    {
      partial: "activities/setup_keyword",
      locals: {
        form_attributes: new? ? {
          as: 'activity',
          url: view.activities_path(type: 'social_giving')
        } : {
          as: 'activity',
          url: view.activity_path,
          method: :put
        },
        activity_config: model.activity_config,
        keyword_extras: "activities/social_giving/setup_keyword_extras",
        keyword_header: "activities/setup_keyword_header",
        existing_keywords: view.current_npo.social_giving_keywords.live
      }.merge(section_locals)
    }
  end

  def setup_images
    {
      partial: "activities/social_giving/setup_images",
      locals: {
        id: 'images',
        heading: 'Images',
        campaigns_keyword: model.activity_config.campaigns_keyword
      }
    }
  end

  def setup_mobile_web
    {
      partial: "activities/social_giving/setup_mobile_web",
      locals: {
        activity_config: model.activity_config,
        campaigns_keyword: model.activity_config.campaigns_keyword
      }.merge(section_locals)
    }
  end

  def setup_fulfillment
    {
      partial: "activities/mobile_pledging/setup_fulfillment",
      locals: {
        activity_config: model.activity_config,
        campaigns_keyword: model.activity_config.campaigns_keyword
      }.merge(section_locals)
    }
  end

  def setup_fundraising_thermometer
    url = view.whitelabel_graph_url(model.activity_config.campaigns_keyword)
    {
      partial: "modularized/setup_fundraising_thermometer",
      locals:  {
               graph_src: url,
               full_screen_url: url,
               graph_for: model.activity_config.campaigns_keyword,
               goal_field: "fundraising_goal",
               update_goal: true,
               is_version2: false,
               fundraising_goal: model.activity_config.campaigns_keyword.fundraising_goal,
               graph_setting: model.activity_config.campaigns_keyword.graph_setting}.merge(section_locals)
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

  protected
  def setup_components
    super
    if !new? && model.activity_config.campaigns_keyword.active?
      append NAVIGATION,
        partial: "activities/social_giving/display_links",
        campaigns_keyword: model.activity_config.campaigns_keyword
    end
  end
end
