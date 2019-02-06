class Themes::Uno::ThemeExhibit < Themes::AbstractThemeExhibit
  def theme_path
    "#{theme_dir}/uno"
  end

  def setup_theme
    before LayoutBuilder::JAVASCRIPTS do
      view.javascript_include_tag "#{theme_path}"
    end

    before LayoutBuilder::STYLESHEETS do
      render_theme_cdn_stylesheet_link_or_inline_css_from_theme_scss_erb_template
    end

    around PageSection::BANNER_SECTION do |content_block|
      navbar default: true do
        container do
          row_and_column column_html: { class: "text-center" }, &content_block
        end
      end
    end

    around PageSection::FOOTER_SECTION do |content_block, options|
      content_tag :footer, &content_block
    end

    define LayoutBuilder::CONTENT, fluid: true

    around Elements::Standard::CardsElement.internal_name do |content_block|
      container &content_block
    end
    around Elements::Standard::HeroElement.internal_name do |content_block|
      row &content_block
    end

    define LayoutBuilder::TITLE do
      view.page_title(nil, page_view.account.accountable.short_name)
    end

    define Elements::Standard::CardsElement.internal_name, cards: []

    append Elements::Standard::CopyrightElement.internal_name do |content_block|
      buffer = ActionView::OutputBuffer.new
      buffer << "&nbsp;&nbsp;<div class='visible-xs'></div>".html_safe
      if view.current_user
        if (page_view.can_edit_page?)
          buffer << render(Elements::Standard::LoginButtonElement.internal_name,
            to: page_view.edit_url,
            label: "Edit",
            with: :link_button,
            wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
            wrapper_tag: :span,
            wrapper_html: { class: "right-large" },
            button: false)
        end

        buffer << render(Elements::Custom::ButtonElement.internal_name,
          to: page_view.logout_url,
          label: "Log Out",
          method: :delete,
          with: :link_button,
          button: false)
      else
        buffer << render(Elements::Custom::ButtonElement.internal_name,
          to: page_view.login_url,
          label: "Is this your page?",
          with: :link_button,
          button: false)
      end
      buffer
    end
  end
end
