class NposCustomFormField

  ATTRIBUTES =
      [
          :field_id,
          :field_name,
          :custom_field_name,
          :control_type,
          :section_id,
          :section_type,
          :field_value,
          :field_options,
          :field_options_editable,
          :mdd_field_name,
          :used_mdd_field_names,
          :payment_field_required,
          :expression,
          :custom_field_template_id,
          :numeric,
          :validations,
          :dependant_fields,
          :dependant_field_options,
          :checkbox_default,
          :calculation_amount,
          :display,
          :is_standard_field,
          :limit_enabled,
          :max_allowed,
          :sold_out_message,
          :limit_label,
          :limit_redirect_url,
          :template_values,
          :template_name,
          :button_label,
          :button_label_char_limit,
          :button_style,
          :button_link,
          :button_form_id,
          :button_link_options,
          :page_element,
          :display_only,
          :image_field
      ]

  attr_accessor *ATTRIBUTES

  def initialize(attributes = {})
    self.field_id = 0
    self.field_options_editable = true
    set_attributes(attributes)
    self.display_only = FormFieldControlType.by_name(self.control_type)[:display_only]
  end

  def set_attributes(attributes)
    if attributes
      ATTRIBUTES.each do |attribute|
        next if attributes[attribute].nil?
        send("#{attribute}=", attributes[attribute])
      end
    end
  end

  def self.load_from(donation_form_setting_custom_field)
    args = {
        field_id: donation_form_setting_custom_field.id,
        field_name: donation_form_setting_custom_field.label,
        mdd_field_name: donation_form_setting_custom_field.merchant_defined_data_field_name,
        section_id: donation_form_setting_custom_field.donation_form_setting_form_section_id,
        numeric: donation_form_setting_custom_field.numeric,
        control_type: donation_form_setting_custom_field.control_type,
        is_standard_field: donation_form_setting_custom_field.standard_field?,
        template_name: donation_form_setting_custom_field.name,
        page_element: donation_form_setting_custom_field.to_page_element,
        image_field: donation_form_setting_custom_field.image_field
    }

    if donation_form_setting_custom_field.rsvp_template? || donation_form_setting_custom_field.standard_field?
      args[:field_options_editable] = false
    end
    args[:custom_field_name] = donation_form_setting_custom_field.standard_field? ? donation_form_setting_custom_field.name
                                 : donation_form_setting_custom_field.npos_custom_field.try(:format_name_for_display)

    args[:validations] = JSON.parse(donation_form_setting_custom_field.validations) rescue {}

    args[:used_mdd_field_names] = donation_form_setting_custom_field.donation_form_setting_custom_form_layout
                                      .used_mapped_field_names(donation_form_setting_custom_field.merchant_defined_data_field_name)
    case donation_form_setting_custom_field.control_type
      when FormFieldControlType::HIDDEN_CONTROL_TYPE
        field_option = donation_form_setting_custom_field.values.first
        if field_option.value_type == NposCustomFormFieldTemplateValue::EXPRESSION_TYPE
          expression_string = field_option.display_value
        else
          args[:field_value] = field_option.display_value
        end
      when FormFieldControlType::CUSTOM_MESSAGE_CONTROL_TYPE, FormFieldControlType::CUSTOM_VIDEO_CONTROL_TYPE
        field_values = donation_form_setting_custom_field.values.first
        args[:field_value] = field_values.display_value if field_values.present?
      when FormFieldControlType::CHECKBOX_CONTROL_TYPE, FormFieldControlType::TERMS_CONDITIONS_CONTROL_TYPE
        field_option = donation_form_setting_custom_field.values.first
        args[:field_value] = field_option.display_name
        args[:checkbox_default] = field_option.display_value == "1" ? true : false
      when FormFieldControlType::CUSTOM_LINK_TYPE
        field_option = JSON.parse(donation_form_setting_custom_field.display_value) rescue {}
        args[:button_label] = field_option['label']
        args[:button_style] = field_option['style']
        args[:button_link] = field_option['link']
        args[:button_form_id] = field_option['form_id']
        args[:button_link_options] = setup_standard_button_link_options(donation_form_setting_custom_field) if field_option.has_key?('form_id')
        args[:button_label_char_limit] = args[:validations]['length'].presence || 20
      when FormFieldControlType::CALCULATED_CONTROL_TYPE
        field_option = donation_form_setting_custom_field.values.first
        args[:display] = JSON.parse(field_option.display_value)["display"] == "true" ? true : false
        args[:calculation_amount] = JSON.parse(field_option.display_value)["result_type"] == "amount" ? true : false
        args[:validations] = donation_form_setting_custom_field.calculated_amount_field? ? true : false
        args[:expression] = JSON.parse(field_option.display_value)["expression"]
        expression_string = field_option.display_value
      when FormFieldControlType::NUMBER_TEXTBOX_CONTROL_TYPE
        args[:field_value] = donation_form_setting_custom_field.values.first.display_value
      when FormFieldControlType::TICKET_ITEM_TYPE
        args[:template_values] = JSON.parse(donation_form_setting_custom_field.values.first.display_value) rescue {}
      when FormFieldControlType::DROPDOWN_CONTROL_TYPE, FormFieldControlType::RICH_RADIO_BUTTONS_CONTROL_TYPE
        template_values = donation_form_setting_custom_field.values
        values_array = []
        template_values.each do |value|
          values_array << [value.display_name, value.display_value]
        end
        args[:template_values] = values_array

        if donation_form_setting_custom_field.dependant_field
          args[:dependant_field_options] = {
              field_name: donation_form_setting_custom_field.dependant_field.label,
              custom_field_name: donation_form_setting_custom_field.dependant_field.npos_custom_field.try(:format_name_for_display),
              mapped_field_name: donation_form_setting_custom_field.dependant_field.merchant_defined_data_field_name,
              used_mdd_field_names: donation_form_setting_custom_field.donation_form_setting_custom_form_layout
                                        .used_mapped_field_names(donation_form_setting_custom_field.dependant_field.merchant_defined_data_field_name)
          }

        end
    end

    if donation_form_setting_custom_field.limits.present?
      args[:limit_enabled] = true
      args[:max_allowed] = donation_form_setting_custom_field.limits.max_allowed
      args[:sold_out_message] = donation_form_setting_custom_field.limits.sold_out_message
      args[:limit_label] = donation_form_setting_custom_field.limits.limit_label
      args[:limit_redirect_url] = donation_form_setting_custom_field.limits.redirect_url
    end
    config = NposCustomFormField.new(args)
    if expression_string.present?
      config.dependant_field_options = config.dependant_fields_map_from(expression_string)
    end
    config
  end

  def self.setup_standard_button_link_options(donation_form_setting_custom_field)
    link_options = []
    if donation_form_setting_custom_field.standard_field?
      page = Page.find_by_donation_form_setting_custom_form_layout_id(donation_form_setting_custom_field.donation_form_setting_custom_form_layout_id)
      if page.present? && page.originable.is_a?(CampaignsKeyword)
        ck = page.originable
        if ck.has_multiple_forms?
          forms = [['Default Donation Form', nil]]
          forms += ck.available_forms.map { |f| [f.form_name, f.id] }
          link_options = forms
        end
      end
    end
    link_options
  end

  def dependant_field_ids
    dependant_field_options.present? ? dependant_field_options.keys.map(&:to_s) : []
  end

  def create_expression(expression_params)
    expression_type = expression_params[:type]
    expr = nil
    case expression_type
      when 'concat'
        field_list = expression_params[:field_list]
        operator = expression_params[:operator]
        expr = field_list.present? ? {expression_type: expression_type, fields: field_list, operator: operator}.to_json : nil
      when 'calculation'
        expr = {expression_type: expression_type, expression: expression_params[:calculation], result_type: expression_params[:result_type], display: expression_params[:display]}.to_json
    end
    expr
  end

  def dependant_fields_map_from(expression)
    fields = {}
    expression_args = JSON.parse(expression)
    case expression_args['expression_type']
      when 'concat'
        field_ids = expression_args['fields']
        if field_ids.present?
          DonationFormSettingCustomField.where(id: field_ids).to_a.each do |cf|
            fields[cf.id] = cf
          end
        end
      when 'calculation'
        calc_expr = expression_args['expression']
        field_ids = field_ids_from_expression(calc_expr)
        NposCustomField.where(id: field_ids).to_a.each do |cf|
          fields[cf.id] = cf
        end
    end
    fields
  end

  def display_expression
    display_expr = ""
    return display_expr unless expression.present?
    display_expr = expression.clone
    dependant_field_ids.each do |id|
      field = NposCustomField.find_by_id(id)
      fld_value = field.present? ? field.format_name_for_display : "DELETED FIELD"
      display_expr.gsub!("<#{id}>", "<#{fld_value}>")
    end
    display_expr
  end

  def field_ids_from_expression(expression)
    return [] unless expression.present?
    field_id_matches = expression.scan(/<(\d+)>/)
    field_ids = []
    field_id_matches.each do |m|
      field_ids += m
    end
    field_ids
  end

end
