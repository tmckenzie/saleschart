class Themes::AbstractThemeForPageExhibit < SimpleDelegator
  def initialize(theme_exhibit)
    super theme_exhibit

    setup
  end

  protected
  def setup_theme_for_page
    raise NotImplementedError
  end

  private
  def setup
    setup_theme_for_page
  end
end