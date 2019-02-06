module Elements
  module Standard
    class TwitterMessageElement < Elements::Custom::TextAreaElement
      display_name "Twitter Sharing"
      content_options shared_setting: SharedSettingType::TWITTER_SHARE_MESSAGE
    end
  end
end