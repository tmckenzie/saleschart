module PageBuilders
  class BasePageBuilder
    attr_accessor :children, :options, :theme_name, :elements, :sections, :current_section

    class << self
      def build(theme=nil)
        raise NotImplementedError
      end

      def provide_options(name, options=nil, &block)
        method_name = "#{name.to_s.demodulize.underscore.gsub(" ", "_")}_options"
        if method_defined?(method_name)
          define_method(method_name) do
            if options
              options.merge(super())
            else
              yield.merge(super())
            end
          end
        elsif block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do
            options
          end
        end
      end
    end

    def initialize(theme_name=nil, &block)
      self.children = []
      self.elements = {}.with_indifferent_access
      self.sections = {}.with_indifferent_access
      self.theme_name = theme_name
      self.instance_exec &block
    end

    def element_migrator(*migration_fields)
      Proc.new do |page|
        originable = page.originable
        if originable.is_a?(CampaignsKeyword)
          settings = PeerFundraiserSetting.find_by_campaigns_keyword_id originable.id
          return_value = nil
          migration_fields.each do |migration_field|
            value = settings.send(migration_field)
            return_value = value if !value.nil?
          end
          return_value
        end
      end
    end

    def section(name, options={}, &block)
      config_method = "#{name.to_s.gsub(" ", "_").underscore}_options"
      config_options = if self.respond_to?(config_method)
        send(config_method)
      else
        {}
      end

      old_children = children
      old_section = self.current_section

      self.children = []
      self.current_section = Sections::BaseSection.new(name, config_options.with_indifferent_access.merge(options).merge(parent_section: current_section), children)
      self.instance_exec &block if block_given?
      sections[name] = current_section

      self.children = old_children
      self.children << self.current_section
      self.current_section = old_section
    end

    def element(klass, options={})
      config_method = "#{klass.to_s.demodulize.underscore}_options"
      config_options = if self.respond_to?(config_method)
        send(config_method)
      else
        {}
      end
      element = klass.new(config_options.with_indifferent_access.merge(options).merge(parent_section: current_section))
      elements[element.internal_name] = element
      children << element
    end

    def default_social_media_section
      section PageSection::SOCIAL_MEDIA_SECTION do
        element Elements::Standard::FacebookMessageElement
        element Elements::Standard::TwitterMessageElement
        element Elements::Standard::TextMessageElement
        element Elements::Standard::EmailMessageElement
      end
    end

    def theme_friendly_name
      raise NotImplementedError
    end

    def method_missing(name, *args)
      element "Elements::Custom::#{name.to_s.classify}Element".constantize, *args
    end
  end
end