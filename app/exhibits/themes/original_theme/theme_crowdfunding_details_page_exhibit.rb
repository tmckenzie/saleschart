class Themes::OriginalTheme::ThemeCrowdfundingDetailsPageExhibit < Themes::OriginalTheme::ThemeCrowdfundingPageExhibit
  TAB_CONTENT_BLOCK_NAME = :tab_content

  def setup_theme_for_page
    skip PageSection::BANNER_SECTION
    setup_back_button(page_view.home_page_url)

    collection = page_collection

    define TAB_CONTENT_BLOCK_NAME,
      with: page_collection_renderer,
      details_type => page_collection,
      component: page_element

    append TAB_CONTENT_BLOCK_NAME do
      row_and_column do
        view.will_paginate collection, renderer: BootstrapPagination::Rails
      end
    end

    define PageSection::MAIN_SECTION,
      partial: "#{theme_path}/components/tabs",
      wrapper: :container,
      container_html: { class: "container-white top-none" },
      details_type: details_type,
      tab_content: TAB_CONTENT_BLOCK_NAME,
      page_title: respond_to?(:page_title) ? page_title : details_type.to_s.titleize

    skip Pages::Components::ComponentsExhibit::FACEBOOK_META_TAGS

    super
  end

  def details_type
    raise NotImplementedError
  end

  def page_element
    raise NotImplementedError
  end

  def page_collection
    raise NotImplementedError
  end

  def page_collection_partial
    raise NotImplementedError
  end
end
