module Elements
  class BaseElement
    include ConfigurationConcerns

    ALL_THEMES = :all
    ALL_PAGES = :all

    RENDERER_OPTION = :type

    add_config :display_name
    add_config :themes, default: ALL_THEMES
    add_config :pages, default: ALL_PAGES
    add_config :default_renderer
    add_config :configurable, default: true
    add_config :hideable, default: true
    add_config :requirable, default: false
    add_config :options
    add_config :configuration_section
    add_config :inline_configuration, default: false, instance_predicate: true
    add_config :required_feature
    add_config :parent_section
    add_config :character_limit
    add_config :transient, default: false, instance_predicate: true

    attr_accessor :element, :local_options, :identifier
    attr_writer :display, :page

    delegate :label, :id,
             :page_section, :set_shared_setting,
             :configuration_option, :npos_custom_form_field_template,
             :persisted?, :position, :goal_type,
             to: :element, allow_nil: true

    def initialize(*args)
      options = args.extract_options!
      @element = args.first
      @local_options = {}.with_indifferent_access

      options.each do |key, value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        elsif "#{key}".ends_with?("_options")
          self.send(key, value)
        end
        local_options[key] = value if !value.is_a?(Proc) || key.to_s.start_with?("default_")
      end
    end

    def self.internal_name
      name.demodulize.gsub("Element", "").titleize
    end

    def internal_name
      identifier || (standard_field? ? self.class.internal_name : "#{self.class.internal_name}_#{self.object_id}")
    end
    alias_method :name, :internal_name

    def renderer
      if (renderer_option = option_for(RENDERER_OPTION)) && element_options_for_theme.include?(renderer_option)
        renderer_option.display_value || default_renderer
      else
        default_renderer
      end
    end
    alias_method :control_type, :renderer

    def <=>(other)
      position <=> other.position
    end

    def standard_field?
      self.class.name.starts_with?("Elements::Standard")
    end

    def parent_configuration_section
      configuration_section || parent_section.configuration_section
    end

    def display(page: nil)
      if !defined?(@display)
        element ? element.display : true
      elsif @display.is_a?(Proc)
        @display.call(page || self.page)
      else
        @display
      end
    end
    alias_method :display?, :display

    def element_options_for_theme
      theme = page.theme
      element_options.select do |option|
        if !option.configurable?
          false
        elsif option.options.key?(:only)
          option.options[:only].include?(theme)
        elsif option.options.key?(:except)
          !option.options[:except].include?(theme)
        elsif option.options.key?(:if)
          option.options[:if].call(self)
        else
          true
        end
      end
    end

    def element_options
      return @element_options if defined?(@element_options)

      @element_options = self.options.map do |option|
        option.clone.tap do |option|
          option.page_element = self
        end
      end
    end

    def option_for(option_name)
      element_options.detect { |option| option.name.to_sym == option_name.to_sym }
    end

    def missing_required_feature?(account)
      if required_feature.present?
        !account.has_feature?(required_feature)
      else
        false
      end
    end

    class << self
      def inherited(child)
        child.class_eval do
          reset_config
        end
      end

      def reset_config
        self.options = if self.options.present?
          self.options.map(&:clone)
        else
          []
        end

        self.display_name = self.to_s.demodulize.gsub("Element", "").titleize
        self.default_renderer ||= self.to_s.demodulize.gsub("Element", "").underscore.to_sym
      end

      def option_for(option_name)
        options.detect { |option| option.name.to_sym == option_name.to_sym }
      end

      def element_options(&block)
        raise ArgumentError if !block_given?

        builder = ConfigurationOptions::Builder.new
        yield builder
        builder.options.each do |option|
          add_config "default_#{option.name}"

          define_singleton_method "#{option.name}_options" do |options|
            option_for(option.name).options = option_for(option.name).options.merge(options)
          end

          define_method "#{option.name}_options" do |options|
            option_for(option.name).options = option_for(option.name).options.merge(options)
          end

          define_method option.name do |*args|
            option_for(option.name).display_value(*args)
          end

          if option.is_a?(ConfigurationOptions::BooleanOption)
            define_method "#{option.name}?" do
              option_for(option.name).display_value
            end
          end

          define_method "#{option.name}=" do |value|
            option_for(option.name).display_value = value
          end
        end
        # self.options ||= []
        self.options += builder.options
      end
    end

    def page
      @page || element.try(:page) || parent_section.try(:page)
    end

  end
end