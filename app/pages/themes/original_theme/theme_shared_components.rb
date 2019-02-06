module Themes
  module OriginalTheme
    module ThemeSharedComponents
      def theme_friendly_name
        "Classic"
      end

      def default_banner_section
        section PageSection::BANNER_SECTION do
          element Elements::Standard::BannerBackgroundImageElement
          section PageSection::BANNER_IMAGES_SECTION do
            element Elements::Standard::BannerLogoElement
            element Elements::Standard::BannerCelebrityImageElement
          end
        end
      end

      def default_footer_section
        section PageSection::FOOTER_SECTION do
          element Elements::Standard::LoginButtonElement
          element Elements::Standard::CopyrightElement
        end
      end
    end
  end
end