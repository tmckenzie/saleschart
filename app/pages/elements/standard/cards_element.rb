module Elements
  module Standard
    class CardsElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::CARDS_RENDERER

      element_options do |option_builder|
        option_builder.image :background_image, shared_setting: SharedSettingType::BACKGROUND_IMAGE, configurable: false
        option_builder.image_style :profile_image_style, display_name: "Display Fundraiser's Profile Picture As", shared_setting: SharedSettingType::PROFILE_PICTURE_TYPE
        option_builder.color :progress_bar_color, shared_setting: SharedSettingType::BRAND_COLOR
      end
    end
  end
end