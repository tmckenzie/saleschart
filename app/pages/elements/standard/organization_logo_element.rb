module Elements
  module Standard
    class OrganizationLogoElement < Elements::Custom::ImageElement
      image_options shared_setting: SharedSettingType::BRAND_LOGO
    end
  end
end