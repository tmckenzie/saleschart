module ConfigurationOptions
  class BaseOption
    # include ConfigurationConcerns
    # include CallWithParams

    add_config :default_value
    add_config :ignore_if_nil, default: false, instance_predicate: true

    attr_accessor :name,
                  :options,
                  :page_element,
                  :shared_setting,
                  :display_name,
                  :display_value

    def initialize(*args)
      self.options = args.extract_options!.with_indifferent_access
      self.name = args.pop.to_sym
      self.page_element = args.first
    end

    def persisted?
      page_element.try(:persisted?)
    end

    def hideable?
      !!options[:hideable]
    end

    def toggled_on?
      !hideable? || page_element.send("show_#{name}?")
    end

    def hide_by_default?
      !!options[:hide_by_default]
    end

    def internal_display_value(page: nil)
      if options.key?(:shared_setting)
        options[:shared_setting]
      else
        display_value(page: page)
      end
    end

    def label_hint
      options[:label_hint]
    end

    def display_value(page: nil, use_default: true)
      page ||= page_element.page
      value = if persisted?
        if options.key?(:shared_setting)
          page_element.element.send(options[:shared_setting])
        elsif template_value = page_element.element.configuration_option(display_name)
          template_value.display_value
        else
          @display_value
        end
      elsif defined?(@display_value)
        @display_value
      elsif options.key?(:display_value)
        options[:display_value]
      elsif is_shared_setting?
        page.send(options[:shared_setting])
      end
      value = call_with_params value, page

      if value != false && use_default && !value.present? && !is_shared_setting?
        value = if !page_element.try(:send, "default_#{name}").nil?
          page_element.send("default_#{name}")
        elsif !options[:default_value].nil?
          options[:default_value]
        elsif !options[:default].nil?
          options[:default]
        else
          default_value
        end
        value = call_with_params value, page
      end

      value
    end

    def display_name
      if options[:display_name].present?
        options[:display_name]
      else
        name.to_s.titleize
      end
    end

    def field_name
      "donation_form_setting_custom_field[#{name}]"
    end

    def field_id
      field_name.gsub('[','_').gsub(']','')
    end

    def control_type
      self.class.to_s.demodulize.underscore
    end

    def is_shared_setting?
      options[:shared_setting].present?
    end

    def shared_setting_name
      options[:shared_setting]
    end

    def configurable?
      if options.key?(:configurable)
        call_with_params options[:configurable], page_element.page
      elsif options.key?(:required_feature)
        page_element.page.account.has_feature?(options[:required_feature])
      else
        true
      end
    end

    def value_type
      if is_shared_setting?
        "shared_setting"
      else
        self.class.to_s.demodulize.gsub("Option", "").underscore
      end
    end
  end
end