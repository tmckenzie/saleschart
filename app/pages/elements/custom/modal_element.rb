module Elements
  module Custom
    class ModalElement < Elements::BaseElement
      element_options do |option_builder|
        # Items for NPOs to configure for an instance of this page element
        #   option_builder.YOUR_OPTION_TYPE :YOUR_OPTION_NAME, OPTIONS_HASH
        #   ex: option_builder.color :color, shared_setting: SharedSettingType::BRAND_COLOR
      end
    end
  end
end