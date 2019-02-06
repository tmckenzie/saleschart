module ConfigurationOptions
  class CarouselOption < BaseOption
    ignore_if_nil true

    def internal_display_value(page: nil)
      @display_value
    end

    def value_type
      if @display_value.is_a?(String)
        NposCustomFormFieldTemplateValue::VIDEO_TYPE
      else
        NposCustomFormFieldTemplateValue::IMAGE_TYPE
      end
    end

    def display_value
      if persisted?
        page_element.element.configuration_options.where(display_name: name).order("`position` ASC")
      end
    end

    def items
      captions = page_element.element.configuration_options.detect {|option| option.display_name == "#{display_name} Captions" } || {}
      if captions.present?
        captions = JSON.parse(captions.display_value)
      end
      CarouselItemOption.build_for(display_value, captions)
    end
  end
end