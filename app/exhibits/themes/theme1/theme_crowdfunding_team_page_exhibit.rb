class Themes::Theme1::ThemeCrowdfundingTeamPageExhibit < Themes::Theme1::ThemeCrowdfundingPageExhibit
  def setup_theme_for_page
    define Elements::Standard::CarouselElement.internal_name,
      items: ConfigurationOptions::CarouselItemOption.build_for(page_view.team_banner_images)
    super
  end
end
