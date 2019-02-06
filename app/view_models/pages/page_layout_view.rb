module Pages
  class PageLayoutView
    attr_reader :page, :page_sections, :page_elements, :page_view,
                :page_section_mappings, :page_section_names,
                :show_hidden_sections_and_elements

    def initialize(page, page_view: nil, theme: nil, show_hidden_sections_and_elements: false)
      @show_hidden_sections_and_elements = show_hidden_sections_and_elements
      @page = page
      @page_sections = []
      @page.preview_theme(theme)
      @page_elements = {}
      @page_section_mappings = {}
      @page_view = page_view
      @page_section_names = []
    end

    def build_page_sections(page_section = nil)
      if page_section
        page_section_view = build_page_section(page_section)
        if page_section_view
          page_section_mappings[page_section_view.section_name] = page_section_view
          page_sections << page_section_view
        end
      else
        page.page_sections.select do |page_section|
          page_section.parent_id.blank? && (page_section.display? || show_hidden_sections_and_elements)
        end.each do |page_section|
          page_section_view = build_page_section(page_section)
          if page_section_view
            page_section_mappings[page_section_view.section_name] = page_section_view
            page_sections << page_section_view
          end
        end
      end
      @page_section_names = page_section_mappings.keys
    end

    def build_page_elements(*elements)
      elements.each do |element|
        build_page_element(element)
      end
    end

    private

    def build_page_element(element)
      page_elements[element.internal_name] = element if element
    end

    def build_page_section(page_section)
      set = SortedSet.new
      set.merge(
        page.page_sections.
        select do |child_page_section|
          child_page_section.parent_id == page_section.id &&
          (child_page_section.display? || show_hidden_sections_and_elements)
        end.
        map do |child_page_section|
          build_page_section(child_page_section).tap do |page_section_view|
            page_section_mappings[page_section_view.section_name] = page_section_view if page_section_view
          end
        end.
        select(&:present?)
      )
      set.merge(
        page_section.donation_form_setting_custom_fields.
        map do |page_element|
          build_page_element(page_element.to_page_element)
        end.
        compact.
        select do |page_element|
          page_view.try(:show_element?, page_element) || show_hidden_sections_and_elements
        end
      )
      if set.present?
        page.theme_section_for(page_section, set)
      end
    end
  end
end