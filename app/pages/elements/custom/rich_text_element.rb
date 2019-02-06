module Elements
  module Custom
    class RichTextElement < Elements::BaseElement
      default_renderer :custom_message
      element_options do |option_builder|
        option_builder.rich_text :content
      end
    end
  end
end