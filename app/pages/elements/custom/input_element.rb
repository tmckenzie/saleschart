module Elements
  module Custom
    class InputElement < Elements::BaseElement
      element_options do |option_builder|
        option_builder.string :label
        option_builder.string :hint
        option_builder.boolean :required, default_value: false
        option_builder.string :maxlength
        option_builder.string :minlength
        option_builder.string :pattern
        option_builder.string :input_type, default_value: "text"
        option_builder.string :placeholder
      end
    end
  end
end