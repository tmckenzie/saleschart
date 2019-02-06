module Themes
  module Theme1
    class CrowdfundingPageBuilder < PageBuilders::CrowdfundingPageBuilder
      include ThemeSharedComponents

      def self.build(theme)
        new(theme) do
          section PageSection::BANNER_SECTION, display_name: "Banner" do
            element Elements::Standard::BannerLogoElement
            element Elements::Standard::BannerDonateButtonElement
            element Elements::Standard::BannerTextElement
          end
          section PageSection::TITLE_SECTION, abstract: true do
            element Elements::Standard::TitleTextElement, configuration_section: PageSection::LEFT_SECTION, display_name: "Text Above Carousel"
          end
          section PageSection::LEFT_SECTION, display_name: "Media Carousel" do
            element Elements::Standard::CarouselElement
          end
          section PageSection::RIGHT_SECTION, display_name: "Goal" do
            element Elements::Standard::TotalRaisedElement, display_name: "Total Amount"
            element Elements::Standard::ProgressBarElement
            section PageSection::STATISTICS_SECTION do
              element Elements::Standard::DonorCountElement
              element Elements::Standard::FundraiserCountElement
            end
            element Elements::Standard::DonateButtonElement, configuration_section: PageSection::CALL_TO_ACTION_BUTTONS_SECTION
            element Elements::Standard::FundraiserButtonElement, configuration_section: PageSection::CALL_TO_ACTION_BUTTONS_SECTION
          end
          section PageSection::CALL_TO_ACTION_BUTTONS_SECTION, display_name: "Buttons"
          section PageSection::MAIN_SECTION, display_name: "Tab Sections" do
            section PageSection::IMPACT_SECTION, renamable: true do
              element Elements::Standard::MainTextElement, character_limit: Page::LONG_TEXT_LIMIT
              element Elements::Standard::OrganizationSummaryElement
            end
            section PageSection::TEAMS_SECTION, display_name: "Teams", remote: true, renamable: true, hideable: true do
              element Elements::Standard::TeamsElement, hideable: false, configurable: false
            end
            section PageSection::FUNDRAISERS_SECTION, remote: true, renamable: true, hideable: true do
              element Elements::Standard::FundraisersElement, hideable: false, configurable: false
            end
            section PageSection::DONORS_SECTION, remote: true, renamable: true, hideable: true do
              element Elements::Standard::DonorsElement, hideable: false, display_name: "Donors Table"
            end
            section PageSection::SOCIAL_SECTION, remote: true, display_name: "Comments", renamable: true, hideable: true do
              element Elements::Standard::CommentsElement, hideable: false, configurable: false
            end
          end

          default_social_media_section
          default_footer_section
        end
      end
    end
  end
end