class Themes::OriginalTheme::ThemeCrowdfundingSharePageExhibit < Themes::OriginalTheme::ThemeCrowdfundingPageExhibit
  def setup_theme_for_page
    swap_in_theme_specific_partials(Pages::Components::ComponentsExhibit::SHARE_RENDERER)

    skip PageSection::BANNER_SECTION
    setup_back_button(page_view.home_page_url)

    define PageSection::MAIN_SECTION,
      with: Pages::Components::ComponentsExhibit::SHARE_RENDERER,
      wrapper: :container,
      container_html: { class: "container-white top-none" }

    skip Pages::Components::ComponentsExhibit::FACEBOOK_META_TAGS

    super
  end
end
