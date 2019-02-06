class Themes::OriginalTheme::ThemeExhibit < Themes::AbstractThemeExhibit
  delegate :peer_fundraiser,
           to: :page_view

  def theme_path
    "#{theme_dir}/original"
  end

  def setup_theme
    before LayoutBuilder::JAVASCRIPTS do
      view.javascript_include_tag "#{theme_path}"
    end

    before LayoutBuilder::STYLESHEETS do
      view.stylesheet_link_tag("#{theme_path}") +
      render_inline_css_from_theme_scss_erb_template("#{theme_path}_supplement")
    end

    swap_in_theme_specific_partials(Elements::Standard::CopyrightElement.internal_name)

    define LayoutBuilder::CONTENT,
      container_html: { class: 'container-white' },
      fluid: true,
      wrapper: :row

    define PageSection::MAIN_SECTION, wrapper: :content_tag, wrapper_html: { class: "fundraiser_container" }

    if page_view.show_section?(PageSection::BANNER_SECTION)
      if !page_view.show_banner_images?
        define(PageSection::BANNER_IMAGES_SECTION, wrapper_html: { class: "fundraiser_banner_empty" })
      else
        define(PageSection::BANNER_IMAGES_SECTION, wrapper_html: { class: "fundraiser_banner" } )
      end
    end
  end
end
