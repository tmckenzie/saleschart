module Elements
  module Custom
    class DeferredContentElement < Elements::BaseElement
      default_renderer :deferred_content
      element_options do |option_builder|
        option_builder.string :label
        option_builder.string :key
      end
    end
  end
end