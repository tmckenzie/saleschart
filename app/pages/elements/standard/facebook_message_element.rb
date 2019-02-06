module Elements
  module Standard
    class FacebookMessageElement < Elements::Custom::TextAreaElement
      display_name "Facebook Sharing"
      content_options shared_setting: SharedSettingType::FACEBOOK_SHARE_MESSAGE
      element_options do |option_builder|
        option_builder.image :image, shared_setting: SharedSettingType::FACEBOOK_SHARE_IMAGE
      end
    end
  end
end