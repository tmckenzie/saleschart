module Themes
  module Theme1
    module ThemeSharedComponents
      extend ActiveSupport::Concern

      included do
      end

      def theme_friendly_name
        "Theme 1"
      end

      def default_footer_section
        section PageSection::FOOTER_SECTION, configurable: false do
          element Elements::Standard::CopyrightElement
        end
      end
    end
  end
end