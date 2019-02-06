module Elements
  module Standard
    class EmailMessageElement < Elements::BaseElement
      display_name "Email Sharing"
      element_options do |option_builder|
        option_builder.string :subject, shared_setting: SharedSettingType::EMAIL_SHARE_SUBJECT
        option_builder.text_area :body, shared_setting: SharedSettingType::EMAIL_SHARE_BODY
      end
      alias_method :content, :body
    end
  end
end