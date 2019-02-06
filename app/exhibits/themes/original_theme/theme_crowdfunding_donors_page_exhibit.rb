class Themes::OriginalTheme::ThemeCrowdfundingDonorsPageExhibit < Themes::OriginalTheme::ThemeCrowdfundingDetailsPageExhibit
  def setup_theme_for_page
    swap_in_theme_specific_partials(Pages::Components::ComponentsExhibit::DONORS_RENDERER)
    define LayoutBuilder::TITLE do
      view.page_title('Donors', page_view.campaigns_keyword.campaign.npo.short_name)
    end
    super
  end

  def details_type
    :donors
  end

  def page_collection
    page_view.donors
  end

  def page_element
    page_view.page.donors_element
  end

  def page_collection_renderer
    Pages::Components::ComponentsExhibit::DONORS_RENDERER
  end
end
