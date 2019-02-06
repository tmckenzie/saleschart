class PageElementView
  def page_element_attrs_from(cf, donation = nil, payment_processor = nil)
    custom_field_template = cf.npos_custom_form_field_template
    if custom_field_template.npos_custom_form_field_template_image.present?
      image_url =custom_field_template.npos_custom_form_field_template_image.send(:custom_image).url
    end
    if custom_field_template.reference_field_template.present?
        mapped_field_name = custom_field_template.reference_field_template.payment_map_from_npo_payment_processor.try(:mapped_field_name)
        extract_field_name = "#{custom_field_template.reference_field_template.npos_custom_field_id}"
        extract_field_name += "-#{mapped_field_name}" if mapped_field_name.present?
    end

    subtitle = ''
    validations = {}
    redirect_sold_out_url = ''
    if cf.numeric
      validations = {number: true}
    end
    if cf.limits && cf.limits.max_allowed.present?
      subtitle = cf.limits.limit_label_html_text(cf.limits.amount_remaining)
      # @error_on_cf_limit_reached[cf.id] = {name: cf.label, message: cf.limits.sold_out_message, redirect_url: cf.limits.redirect_url}
      if cf.limits.amount_remaining == 0
        redirect_sold_out_url << cf.limits.redirect_url if cf.limits.redirect_url.present?
        subtitle = cf.limits.sold_out_error_text
        validations.merge!(disabled: true)
      else
        remaining_limit = cf.limits.amount_remaining
        if custom_field_template.control_type == FormFieldControlType::TEXTBOX_CONTROL_TYPE
          validations.merge!(range: [0, cf.limits.amount_remaining])
        end
      end
    end
    if cf.validations.present? && cf.validations == "amount"
      validations.merge!({total_amount: true})
    end

    field_length = payment_processor.present? ? payment_processor.field_length : NposCustomFormFieldTemplate::MAX_FIELD_LENGTH

    options = []
    override_val = override_custom_field_value(donation, custom_field_template.npos_custom_field_id) if donation.present?
    hidden_control_type = custom_field_template.control_type == FormFieldControlType::HIDDEN_CONTROL_TYPE
    custom_field_template.npos_custom_form_field_template_values.each do |cf_value|
      optional_field_attrs = {}
      if cf_value.value_type == NposCustomFormFieldTemplateValue::EXPRESSION_TYPE
        display_value = ''
        expression = JSON.parse(cf_value.display_value)
        set_expression_fields(expression)
      else
        display_value = hidden_control_type && override_val.present? ? override_val : cf_value.display_value
        expression = ""
        if remaining_limit.present? && StringUtil.numeric?(display_value) && display_value.to_f > remaining_limit
          optional_field_attrs[:disabled] = true
        end
      end

      options << [cf_value.display_name, display_value, expression, optional_field_attrs]
    end

    {
        id: cf.id, label: cf.label, field_type: custom_field_template.control_type,
        length: field_length, options: options, numeric: cf.numeric, validations: validations, subtitle: subtitle,
        display: cf.display, hidden: hidden_control_type, position: cf.position,
        section_id: cf.donation_form_setting_form_section_id, image_url: image_url, extract_field_name: extract_field_name,
        redirect_sold_out_url: redirect_sold_out_url, override_val: override_val, rsvp_template: cf.rsvp_template?
    }
  end

  def set_expression_fields(expr)
    if expr['fields'].present?
      dependant_field_names = []
      expr['fields'].each do |fld|
        custom_field = DonationFormSettingCustomField.find_by_id fld
        custom_template = custom_field.npos_custom_form_field_template if custom_field.present?
        mapped_field_name = custom_template.payment_map_from_npo_payment_processor.mapped_field_name if custom_template.present?
        dependant_field_names << "#{custom_template.npos_custom_field_id}-#{mapped_field_name}" if mapped_field_name.present?
      end
      expr['fields'] = dependant_field_names
    end
  end

  def override_custom_field_value(donation, field_id)
    override_val = ''
    originables = []
    originables << {originable_id: donation.peer_fundraiser_id, originable_type: NposCustomFieldsOverrideType::PEER_FUNDRAISER_OVERRIDE_TYPE} if donation.peer_fundraiser_id
    override = NposCustomFieldsOverride.find_override_by(field_id, originables)
    override_val = override.override_value if override
    override_val
  end

end