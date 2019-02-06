class PaymentProcessorFormBuilder
  def initialize
  end

  def control_options
    [
        ["Text Field", "text_field"],
        ["Text Area", "text_area"],
        ["True/False", "select"]
    ]
  end

  def generate_field(option, form, disabled = false)
    case option.option_type
      when 'text_field'
        generate_text_field(option, form, disabled)
      when 'text_area'
        generate_text_area(option, form, disabled)
      when 'select'
        generate_drop_down(option, form, disabled)
    end
  end

  def generate_label(option, form)
    form.label :"#{option.option_name}", option.option_name.gsub(/_/, " ").titleize
  end

  def generate_text_field(option, form, disabled = false)
    form.send(:"#{option.option_type}", :"#{option.option_name}", class: 'form-control', disabled: disabled)
  end

  def generate_text_area(option, form, disabled = false)
    form.send(:"#{option.option_type}", :"#{option.option_name}", { rows: 5, class: 'form-control', disabled: disabled })
  end

  def generate_drop_down(option, form, disabled = false)
    form.send(:"#{option.option_type}", :"#{option.option_name}",['false', 'true'], {}, class: 'form-control', disabled: disabled)
  end
end