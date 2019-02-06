module Themes
  module Uno
    module ThemeSharedComponents
      extend ActiveSupport::Concern

      included do

      end

      def theme_friendly_name
        "Uno"
      end

      def default_banner_section
        section PageSection::BANNER_SECTION do
          element Elements::Standard::BannerLogoElement, configurable: false, hideable: false
        end
      end

      def default_main_section
        section PageSection::MAIN_SECTION, display_name: "Tile" do
          element Elements::Standard::HeroElement,
            configuration_section: PageSection::BANNER_SECTION#, inline_configuration: true,
          element Elements::Standard::CardsElement#, inline_configuration: true
        end
      end

      def default_footer_section
        section PageSection::FOOTER_SECTION, configurable: false do
          element Elements::Standard::CopyrightElement
        end
      end
    end
  end
end