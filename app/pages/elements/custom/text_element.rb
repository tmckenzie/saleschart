module Elements
  module Custom
    class TextElement < Elements::BaseElement
      default_renderer :custom_message
      element_options do |option_builder|
        option_builder.string :content
      end
    end
  end
end