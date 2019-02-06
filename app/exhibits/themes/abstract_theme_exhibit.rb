class Themes::AbstractThemeExhibit < SimpleDelegator
  attr_reader :page_exhibit

  def initialize(page_exhibit)
    @page_exhibit = page_exhibit
    super page_exhibit

    setup
  end

  def theme_dir
    "public/themes"
  end

  def render_theme_cdn_stylesheet_link_or_inline_css_from_theme_scss_erb_template(template=theme_path)
    if view.params[:preview].present?
      render_inline_css_from_theme_scss_erb_template
    elsif page_view.page.css_path.blank?
      css = PageBuilderService.publish("#{template}.scss", page_view)
      content_tag(:style, css.html_safe)
    else
      view.stylesheet_link_tag(page_view.page.css_path, media: "all")
    end
  end

  def render_inline_css_from_theme_scss_erb_template(template=theme_path)
    css = PageBuilderService.compile_css("#{template}.scss", page_view)
    content_tag(:style, css.html_safe)
  end

  def theme_path
    raise NotImplementedError
  end

  def swap_in_theme_specific_partials(*components)
    components.each do |component|
      define component, partial: "#{theme_path}/components/#{component.to_s.downcase.gsub("_renderer", "").gsub(" ", "_")}"
    end
  end

  def render_section(section_name)
    # No-op
  end

  protected
  def setup_theme
    raise NotImplementedError
  end

  def setup_theme_for_page
    page_type = page_exhibit.class.to_s.scan(/::(\w+)Exhibit/).first.first
    c = "#{self.class.parent.to_s}::Theme#{page_type}Exhibit".constantize rescue nil
    if !c
      c = "#{self.class.parent.to_s}::Theme#{page_view.page.class.name}Exhibit".constantize rescue nil
    end
    c.try(:new, self)
  end

  private
  def setup
    setup_theme_for_page
    setup_theme
  end
end