module Elements
  module Standard
    class TextMessageElement < Elements::Custom::TextAreaElement
      display_name "Text Message Sharing"
      content_options shared_setting: SharedSettingType::TEXT_SHARE_MESSAGE
    end
  end
end