module Navigation
  class Page
    ATTRIBUTES =
        [
            :heading, :sub_heading, :page_url, :referrer
        ]

    attr_accessor *ATTRIBUTES, :page_sections
    attr_writer :current_page_section

    def initialize(attributes={})
      set_attributes(attributes)
      @page_sections = []
    end

    def set_attributes(attributes)
      if attributes
        ATTRIBUTES.each do |attribute|
          next if attributes[attribute].nil?
          send("#{attribute}=", attributes[attribute])
        end
      end
    end

    def add_section(section)
      page_sections << section
    end

    def add_section_from(attrs = {})
      section = Navigation::PageSection.new(attrs)
      section.url = "#{page_url}?section=#{section.id}&referrer=#{referrer}" if page_url.present?
      self.current_page_section = section if section.default
      page_sections << section
    end

    def current_page_section
      @current_page_section ||= page_sections.first
    end

    def find_section_by(id)
      page_sections.detect { |section| section.id == id }
    end
  end
end