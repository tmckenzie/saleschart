class Themes::OriginalTheme::ThemeCrowdfundingTeamsPageExhibit < Themes::OriginalTheme::ThemeCrowdfundingDetailsPageExhibit
  def setup_theme_for_page
    define Pages::Components::ComponentsExhibit::TEAMS_RENDERER,
      partial: 'public/themes/original/components/teams'
    super
  end

  def details_type
    :teams
  end

  def page_collection
    page_view.teams
  end

  def page_element
    page_view.page.donors_element
  end

  def page_collection_renderer
    Pages::Components::ComponentsExhibit::TEAMS_RENDERER
  end

  def page_title
    "Fundraising Teams"
  end
end
