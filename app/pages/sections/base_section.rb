module Sections
  class BaseSection
    attr_accessor :name
    attr_accessor :options
    attr_accessor :children
    attr_accessor :domain_section
    attr_writer :page

    def initialize(name, options, children=[], domain_section=nil)
      self.name = name
      self.options = options
      self.children = children
      self.domain_section = domain_section
      self.page = options.delete(:page)
    end
    alias_method :section_name, :name

    delegate :position, to: :domain_section

    def page
      @page || parent_section.try(:page)
    end

    def display?
      if domain_section
        domain_section.display?
      else
        true
      end
    end

    def id
      if domain_section
        domain_section.id
      else
        name.parameterize
      end
    end

    def parent_section
      options[:parent_section]
    end

    def configuration_section
      if parent_section.nil? || parent_section.abstract?
        self.name
      else
        parent_section.configuration_section
      end
    end

    def abstract?
      !!options[:abstract]
    end

    def configurable?
      !options.key?(:configurable) || options[:configurable]
    end

    def hideable?
      !!options[:hideable]
    end

    def <=>(other)
      position <=> other.position
    end

    def display_name
      if domain_section && renamable?
        domain_section.display_name
      elsif options.key?(:display_name)
        options[:display_name]
      else
        "#{name.titleize}"
      end
    end

    def default_display_name
      if options.key?(:display_name)
        options[:display_name]
      else
        "#{name.titleize}"
      end
    end

    def renamable?
      !!options[:renamable]
    end

    def renderer
      :page_section
    end

  end
end