module Elements
  module Custom
    class LinkElement < Elements::BaseElement
      add_config :button, default: false

      element_options do |option_builder|
        option_builder.string :link_text, maxlength: 20
        option_builder.string :url, configurable: false
      end
    end
  end
end