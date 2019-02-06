class Themes::OriginalTheme::ThemeInactivePageExhibit < Themes::AbstractThemeForPageExhibit
  def setup_theme_for_page
    define PageSection::MAIN_SECTION, column_html: { class: "padding-top-xlarge padding-bottom-xlarge text-center" }, wrapper: :column

    prepend PageSection::MAIN_SECTION do
      view.image_tag(page_view.page.brand_logo, alt: page_view.page_title) + "<br/><br/>".html_safe
    end if page_view.page.brand_logo.present?

    surround PageSection::FOOTER_SECTION do |content_block|
      column do
        content_tag :div, class: "fundraiser_mc_footer", &content_block
      end
    end
  end
end