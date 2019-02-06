module Elements
  module Standard
    class MainTextElement < Elements::Custom::RichTextElement
      content_options shared_setting: SharedSettingType::CROWDFUNDING_CALL_TO_ACTION
      hideable false
    end
  end
end