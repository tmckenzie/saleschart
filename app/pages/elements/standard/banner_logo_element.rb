module Elements
  module Standard
    class BannerLogoElement < Elements::Custom::ImageElement
      image_options shared_setting: SharedSettingType::BRAND_LOGO
    end
  end
end