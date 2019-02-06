class Pages::ConfigView
  attr_accessor :view, :page, :theme_layout

  def initialize(view, page)
    self.view = view
    self.page = page
    self.theme_layout = page.theme_layout(page.theme)
  end

  def configuration_sections
    if @configuration_sections
      @configuration_sections
    else
      layout = {}

      theme_layout.elements.values.each do |base_element|
        configuration_section_name = base_element.parent_configuration_section
        element = page.theme_element_for(base_element.internal_name)

        if !layout.key?(configuration_section_name)
          base_section = build_page_section(section_name: configuration_section_name)
          if !base_section.configurable?
            next
          end
          layout[configuration_section_name] = base_section
        end

        configuration_section_options = layout[configuration_section_name].children

        section = element.parent_section if element
        until section.nil?
          if (section.renamable? || section.hideable?) && !configuration_section_options.map(&:name).include?(section.name)
            configuration_section_options << build_page_section(base_section: section)
          end
          section = section.parent_section
        end

        configuration_section_options << element if element && (element.hideable? || element.configurable?)
      end

      @configuration_sections = layout.values
    end
  end

  def default_tab_options
    available_tabs = page.page_sections.where(base_section: PageSection::MAIN_SECTION).order("position asc")
    if page.account.accountable_type == Account::AccountType::NPO && !page.account.has_feature?(Feature::CROWDFUNDING)
      available_tabs = available_tabs.reject {|section| section.section_name == PageSection::TEAMS_SECTION }
    end
    view.options_for_select(available_tabs.map do |tab|
      [tab.display_name, tab.section_name]
    end, selected: page.default_selected_tab, disabled: available_tabs.reject(&:display?).map(&:section_name))
  end

  private

  def build_page_section(base_section: nil, section_name: base_section.name)
    db_page_sections = page.page_sections

    base_section = theme_layout.sections[section_name] if base_section.nil?
    db_page_section = db_page_sections.detect {|section| section.section_name == section_name }
    section_options = base_section ? base_section.options : { abstract: true }.with_indifferent_access

    Sections::BaseSection.new(section_name, section_options, [], db_page_section)
  end
end