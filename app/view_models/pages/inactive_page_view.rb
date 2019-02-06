module Pages
  class InactivePageView < PageView
    attr_accessor :object

    def initialize(view, page, object)
      self.object = object
      super view, page, Theme::ORIGINAL
    end

    def page_sections
      [
        Sections::BaseSection.new(PageSection::MAIN_SECTION, {}, [
          Elements::Standard::InactiveMessageElement.new
        ]),
        Sections::BaseSection.new(PageSection::FOOTER_SECTION, {}, [
          Elements::Standard::CopyrightElement.new
        ])
      ]
    end

    def page_section_names
      page_sections.map(&:name)
    end

    def page_elements
      page_sections.map(&:children).flatten.map {|element| [element.name, element]}
    end

    def page_title
      object.campaign.npo.short_name
    end
  end
end