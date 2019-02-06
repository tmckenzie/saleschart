class Pages::InactivePageExhibit < Pages::AbstractPageExhibit
  def setup_page
    define LayoutBuilder::TITLE do
      view.page_title(page_view.page_title)
    end
  end
end
