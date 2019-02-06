class DonationFormFields

  FORM_FIELDS =
      [
          :cc_number_field,
          :cc_expiry_date_field,
          :cc_cvv_field, # For BT
          :cc_type_field,
          :amount_field,
          :recurring_frequency,
          :calculated_amount,
          :processing_fee
      ]

  attr_accessor *FORM_FIELDS, :lookup_url, :lookup_enabled, :redirect_sold_out
  attr_reader :hidden_fields, :recurring_terms_url, :custom_fields, :standard_fields, :form_fields, :form_url, :donation, :payment_processor

  def initialize(payment_processor, donation, attributes = {})
    @payment_processor = payment_processor
    @donation = donation
    @hidden_fields = {}
    @recurring_terms_url = RecurringDonation::CURRENT_TERMS_URL
    @custom_fields = []
    @form_fields = {}
    @lookup_enabled = false
    @redirect_sold_out = []
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    if attributes
      @amount_field = {name: :amount, value: attributes[:amount], label: "Amount", placeholder: "10", required: true}
      @cc_number_field = {name: :card_number, value: '', label: "Card Number", placeholder: "XXXX XXXX XXXX XXXX", required: true}
      @cc_expiry_date_field = {name: :expiration_date, value: attributes[:cc_expiry_date], label: "Expiration Date", placeholder: "MM/YYYY", required: true}
      if @payment_processor.present? && @payment_processor.requires_cc_type_request_param?
        @cc_type_field = {name: :card_type, value: '', required: true}
      end
      if @payment_processor.present? && @payment_processor.supports_recurring?
        @recurring_frequency = {name: :recurring_frequency, value: attributes[:recurring_frequency]}
      end
      @processing_fee = attributes[:processing_fee]
    end
  end

  def set_hidden_fields(fields = {})
    # Randomize order
    Hash[*fields.to_a.shuffle.flatten].each do |k, v|
      @hidden_fields[k] = v
    end
  end

  def set_custom_fields(custom_fields = [])
    @custom_fields = custom_fields
    @custom_fields.each do |cf|
      cf[:name] = "custom_fields[#{cf[:name]}]"
      if cf[:calculated_amount].present?
        @amount_field = cf[:calculated_amount]
      end
    end
  end

  def set_standard_fields(standard_fields = [])
    @standard_fields = standard_fields
    standard_fields.each do |sf|
      if @payment_processor.present? && @payment_processor.requires_standard_field_request_param?(sf[:name])
        sf[:required] = true
      end
      if sf[:name] == DonationFormStandardField::CVV_FIELD
        @cc_cvv_field = sf
        standard_fields.delete(sf)
        break
      end
    end
  end

  def recurring_frequency_value
    @recurring_frequency.present? ? @recurring_frequency[:value] : nil
  end

  def build_form_fields(post_back_args = {})
    form = donation.form
    post_back_args ||= {}
    post_back_custom_fields = post_back_args[:custom_fields].presence || custom_fields_info_args(donation)
    post_back_custom_fields_map = post_back_custom_fields.stringify_keys.with_indifferent_access if post_back_custom_fields.present?
    post_back_custom_labels_map = post_back_args[:custom_labels].stringify_keys.with_indifferent_access if post_back_args[:custom_labels].present?
    form.sections.each do |section|
      @form_fields[section.id] = []
      section.form_fields.each do |cf|
        args = {}
        if cf.standard_field
          val = post_back_args.present? ? post_back_args[cf.name.to_sym] : ''
          std_field = DonationFormStandardField.find_by_name(cf.name)
          if std_field.present?
            options = std_field[:fld_type] == FormFieldControlType::CHECKBOX_CONTROL_TYPE ? [[cf.label, '0']] : std_field[:select_options]
            args = {
              id: cf.id, name: cf.name, placeholder: std_field[:placeholder],
              label: cf.label, value: val, field_type: std_field[:fld_type],
              options: options, sublabel: std_field[:sublabel], position: cf.position,
              validations: std_field[:validations], section_id: cf.donation_form_setting_form_section_id
            }
          end
          if payment_processor.present? && payment_processor.requires_standard_field_request_param?(args[:name])
            args[:required] = true
          end
          if args[:name] == DonationFormStandardField::CVV_FIELD
            @cc_cvv_field = args
            next
          end
        else
          args = PageElementView.new.page_element_attrs_from(cf, donation, payment_processor)
          @redirect_sold_out << args[:redirect_sold_out_url] if args[:redirect_sold_out_url].present?

          if cf.npos_custom_field.present?
            custom_field_name = cf.npos_custom_field.id
            val = post_back_custom_fields_map.present? ?
                    post_back_custom_fields_map[custom_field_name.to_s] : args[:override_val]
            # Append PP's field mapper name if exists
            if cf.merchant_defined_data_field_name.present?
              custom_field_name = "#{custom_field_name}-#{cf.merchant_defined_data_field_name}"
            end
            args.merge!(name: "custom_fields[#{custom_field_name}]", value: val)
          end

          if cf.control_type ==  FormFieldControlType::CUSTOM_MESSAGE_CONTROL_TYPE
            val = post_back_custom_labels_map.present? ? post_back_custom_labels_map[cf.id.to_s] : args[:override_val]
            args.merge!(name: cf.label, value: val)
          end
          if args[:calculated_amount].present?
            @amount_field = args[:calculated_amount]
          end
        end

        @form_fields[section.id] << args
      end
    end
  end

  def custom_fields_info_args(donation)
    ret = {}
    donation.form.custom_fields.each do |cf|
      cust_id = cf.npos_custom_field.try(:id)
      cust_field_val = NposConstituentNposCustomField.where(npos_constituent_id: donation.npos_constituent_id, npos_custom_field_id: cust_id).first if cust_id.present?
      ret[cust_id.to_s.to_sym] = cust_field_val.custom_field_value if cust_field_val.present?
    end
    ret
  end

end
