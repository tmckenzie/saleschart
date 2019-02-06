class MobileMessagingActivityExhibit < ActivityExhibit
  def config_page_navigation
    super
    @page.add_section_from(id: 'keyword', heading: 'Keyword', action: 'setup_keyword', default: true)
  end

  def setup_keyword
    {
      partial: "activities/setup_keyword",
      locals: {
        id: 'keyword', heading: 'Keyword',
        form_attributes: new? ? {
          as: 'activity',
          url: context.activities_path(type: 'mobile_messaging')
        } : {
          as: 'activity',
          url: context.activity_path,
          method: :put,
          remote: true
        },
        activity_config: model.activity_config,
        keyword_extras: "activities/mobile_messaging/setup_keyword_extras",
        keyword_header: "activities/setup_keyword_header",
        existing_keywords: context.current_npo.communication_keywords.live
      }
    }
  end
end
