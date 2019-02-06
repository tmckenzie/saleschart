class Pages::ConfiguratorExhibit < Blocks.builder_class
  attr_accessor :page, :element_to_section_mappings

  def initialize(page, view)
    self.page = page
    # self.view_model = view_model
    self.element_to_section_mappings = HashWithIndifferentAccess.new {|h,k| h[k] = []; h[k] }
    super view
  end

  def render_row(row)
    render(row[:name], row[:locals].merge(partial: row[:partial], wrapper: :configuration_section))
  end

  def page_sections(form = nil)
    rows = []
    build_page_section_to_elements_mappings
    page_layout.page_sections.each do |page_section|
      next if !page_section.configurable?
      rows += add_page_section_rows(page_section, form)
    end
    rows
  end

  def configuration_section(options, &block)
    view.render_with_overrides options.merge(section: options[:display_name], partial: "pages/configuration_section"), &block
  end

  private

  def build_page_section_to_elements_mappings
    page_layout.build_page_sections
    page_layout.page_elements.each do |element_name, element|
      element_to_section_mappings[element.parent_configuration_section] << element
    end
  end

  def page_layout
    @page_layout ||=
      ::Pages::PageLayoutView.new(page, show_hidden_sections_and_elements: true)
  end

  def section_rows(section, form)
    rows = []
    rows <<
        {
            name: section.section_name,
            # partial: 'pages/custom_section',
            partial: 'pages/page_rows',
            # 'pages/page_rows', locals: { section: section, section_elements: section_elements }
            locals: {
              section: section,
              section_elements: element_to_section_mappings[section.name],
              f: form,
              page: page ,
              display_name: section.display_name
            }
        }
    rows
  end

  def add_page_section_rows(page_section, form)
    if page_section.abstract?
      rows = []
      page_section.children.each do |child_page_section|
        if child_page_section.is_a?(Sections::BaseSection)
          rows += add_page_section_rows(child_page_section, form)
        end
      end
      rows
    else
      section_rows(page_section, form)
    end
  end
end