class Themes::Theme1::ThemeExhibit < Themes::AbstractThemeExhibit
  def theme_path
    "#{theme_dir}/theme_1"
  end

  def setup_theme
    before LayoutBuilder::JAVASCRIPTS do
      view.javascript_include_tag "#{theme_path}"
    end

    before LayoutBuilder::STYLESHEETS do
      view.stylesheet_link_tag("https://fonts.googleapis.com/css?family=Abel") +
      view.stylesheet_link_tag("https://fonts.googleapis.com/css?family=The+Girl+Next+Door") +
      view.stylesheet_link_tag("https://fonts.googleapis.com/css?family=Shadows+Into+Light") +
      render_theme_cdn_stylesheet_link_or_inline_css_from_theme_scss_erb_template
    end

    define LayoutBuilder::CONTENT,
           container_html: { id: 'main-container' },
           wrapper: :row

    around PageSection::BANNER_SECTION do |content_block, options|
      navbar options.merge(default: true, fixed: :top), &content_block
    end
    surround PageSection::BANNER_SECTION do |content_block|
      container container_html: { class: "no-padding" } do
        row_and_column &content_block
      end
    end

    define Elements::Standard::BannerTextElement.internal_name,
      wrapper: :content_tag,
      wrapper_html: { class: "navbar-text", id: "navbar-description" }
    define PageSection::TITLE_SECTION,
      wrapper: :column
    define PageSection::LEFT_SECTION, wrapper: :column, md: 8, xs: 12
    define PageSection::RIGHT_SECTION, wrapper: :column, md: 4, xs: 12
    define PageSection::MAIN_SECTION, wrapper: :column
    around PageSection::FOOTER_SECTION do |content_block, options|
      column do
        content_tag :footer, align: "center", class: "top-xlarge", &content_block
      end
    end

    define Elements::Standard::BannerLogoElement.internal_name, image_html: { class: "logo", alt: "#{page_view.account_name} Logo" }
  end

  def render_section(section_name)
    case section_name
      when PageSection::STATISTICS_SECTION
        render_components 'donor_count', 'fundraiser_count', 'progress_bar', 'total_raised'
      when PageSection::DONORS_SECTION
        render_components 'donors', 'donor_count', 'progress_bar', 'total_raised'
      when PageSection::FUNDRAISERS_SECTION
        render_components 'fundraisers', 'fundraiser_count'
      when PageSection::TEAMS_SECTION
        render_components 'teams'
    end
  end

  private

  def render_components(*component_names)
    components = {}
    component_names.each{ |name| components[name] = page_view.page.send("#{name}_element") }
    page_view.page_layout.build_page_elements(*components.values)
    page_view.page_layout.page_elements.each do |key, element|
      define key, with: element.renderer
    end
    html = []
    components.each do |component_name, page_element|
      html << send("render_#{component_name}_component", page_element) if page_element
    end
    html
  end

  def render_total_raised_component(total_raised_element)
    render(total_raised_element.internal_name, total_raised: page_view.fundraising_total, component: page_view.total_raised_element)
  end

  def render_progress_bar_component(progress_bar_element)
    render(progress_bar_element.internal_name, component: progress_bar_element,
                        goal: page_view.fundraising_goal,
                        total: page_view.fundraising_total,
                        progress: page_view.fundraising_progress)
  end

  def render_fundraiser_count_component(fundraiser_count_element)
    render(fundraiser_count_element.internal_name, fundraiser_count: page_view.fundraisers.length, wrapper: nil)
  end

  def render_donor_count_component(donor_count_element)
    render(donor_count_element.internal_name, donor_count: page_view.donor_count, wrapper: nil)
  end

  def render_donors_component(donors_element)
    render(donors_element.internal_name, component: donors_element, donors: page_view.donors, wrapper: nil)
  end

  def render_fundraisers_component(fundraisers_element)
    render(fundraisers_element.internal_name, fundraisers: page_view.fundraisers.
      paginate(per_page: page_view.pagination_options[:per_page], page: page_view.pagination_options[:page]))
  end

  def render_teams_component(teams_element)
    render(teams_element.internal_name, teams: page_view.teams)
  end
end