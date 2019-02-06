module Elements
  module Standard
    class OrganizationSummaryElement < Elements::Custom::RichTextElement
      content_options shared_setting: SharedSettingType::ORG_SUMMARY
      hideable false
    end
  end
end