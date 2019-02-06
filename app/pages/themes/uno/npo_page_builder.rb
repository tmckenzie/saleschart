module Themes
  module Uno
    class NpoPageBuilder < PageBuilders::NpoPageBuilder
      include ThemeSharedComponents

      def self.build(theme)
        new(theme) do
          default_banner_section
          default_main_section
          default_footer_section
        end
      end
    end
  end
end