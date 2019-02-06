module Elements
  module Custom
    class MultipleFormsButtonElement < Elements::Custom::ButtonElement
      # This is the text that will appear for the first option in the configurator
      #  i.e. the default option with a value of nil
      add_config :default_form_option_text
      link_text_options maxlength: 20

      def form_options
        forms = [[default_form_option_text, nil]]
        forms += page.originable.available_forms.map { |f| [f.form_name, f.id] }
        forms
      end

      element_options do |option_builder|
        option_builder.collection :form_id,
          items: lambda { |element| element.form_options }
      end
    end
  end
end