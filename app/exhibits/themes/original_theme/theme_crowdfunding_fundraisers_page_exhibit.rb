class Themes::OriginalTheme::ThemeCrowdfundingFundraisersPageExhibit < Themes::OriginalTheme::ThemeCrowdfundingDetailsPageExhibit
  def setup_theme_for_page
    define Pages::Components::ComponentsExhibit::FUNDRAISERS_RENDERER,
      partial: 'public/themes/original/components/fundraisers'
    super
  end

  def details_type
    :fundraisers
  end

  def page_collection
    page_view.fundraisers.paginate(per_page: page_view.pagination_options[:per_page], page: page_view.pagination_options[:page])
  end

  def page_element
    page_view.page.fundraisers_element
  end

  def page_title
    page_view.team_page? ? "Members" : "Participants"
  end

  def page_collection_renderer
    Pages::Components::ComponentsExhibit::FUNDRAISERS_RENDERER
  end
end
