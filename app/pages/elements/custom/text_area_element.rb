module Elements
  module Custom
    class TextAreaElement < Elements::BaseElement
      default_renderer :custom_message
      element_options do |option_builder|
        option_builder.text_area :content
      end
    end
  end
end