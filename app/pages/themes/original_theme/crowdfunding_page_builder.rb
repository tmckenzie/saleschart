module Themes
  module OriginalTheme
    class CrowdfundingPageBuilder < PageBuilders::CrowdfundingPageBuilder
      include ThemeSharedComponents

      def self.build(theme)
        new(theme) do
          default_banner_section

          section PageSection::MAIN_SECTION do
            element Elements::Standard::MainTextElement
            element Elements::Standard::ProgressBarElement
            element Elements::Standard::DonorsElement, hideable: false
            section PageSection::CALL_TO_ACTION_BUTTONS_SECTION do
              element Elements::Standard::DonateButtonElement
              element Elements::Standard::FundraiserButtonElement
              element Elements::Standard::ShareButtonElement
            end

            section PageSection::ORGANIZATION_SECTION do
              element Elements::Standard::OrganizationLogoElement
              element Elements::Standard::OrganizationSummaryElement
            end
          end

          default_footer_section
          default_social_media_section
        end
      end
    end
  end
end