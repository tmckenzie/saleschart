class DonationFormFieldsExhibit < Exhibit
  attr_reader :form_settings

  def form_popup_rows(form_settings)
    @form_settings = form_settings
    rows = []
    form_settings.popup_sections.each do |section_name, section|
      section_rendering_method = "#{section_name}_section_rows".to_sym
      if respond_to?(section_rendering_method)
        rows += send(section_rendering_method, section)
      end
    end
    rows
  end

  def form_section_rows(form_settings)
    @form_settings = form_settings
    @payment_form_type = form_settings.sub_type != DonationFormSetting::NONPAYMENT_SUBTYPE

    rows = []
    form_settings.body_sections.each do |section_name, section|
      section_rendering_method = "#{section_name}_section_rows".to_sym
      if respond_to?(section_rendering_method)
        rows += send(section_rendering_method, section)
      else
        rows += custom_section_rows(section)
      end
      rows
    end
    rows
  end

  def section_heading_row(section)
    section[:display_name].present? ?
      {
        partial: 'public/shared/section_heading',
        locals: { section: section }
      } : {}
  end

  def amount_section_rows(section)
    rows = []
    display_amount = @payment_form_type || form_settings.has_calculated_amount_field
    if display_amount
      rows << section_heading_row(section)
    end
    if form_settings.has_calculated_amount_field

      rows <<
        {
          partial: 'public/shared/amount_field',
          locals: {
            donation_form_settings: form_settings,
            donation_form: model,
            hide: true
          }
        }
    elsif @payment_form_type
      rows <<
        {
          partial: 'public/shared/donation_form_amount_section',
          locals: {
            donation_form_settings: form_settings,
            donation_form: model
          }
        }

    end
    rows <<
      {
        partial: 'public/shared/form_fields',
        locals: {
          section: section,
          donation_form_settings: form_settings,
          donation_form: model
        }
      }
    rows
  end

  def frequency_section_rows(section)
    rows = []
    if @payment_form_type && form_settings.display_frequency && model.recurring_frequency
      rows <<
        {
          partial: 'public/shared/donation_form_frequency_section',
          locals: {
            donation_form_settings: form_settings,
            donation_form: model,
            section: section,
          }
        }
    end
    rows
  end

  def personal_section_rows(section)
    rows = []
    if section[:displayable]
      rows << section_heading_row(section)
      rows <<
        {
          partial: 'public/shared/form_fields',
          locals: {
            section: section,
            donation_form_settings: form_settings,
            donation_form: model
          }
        }
    end
    rows
  end

  def payment_section_rows(section)
    rows = []
    if @payment_form_type
      rows <<
        {
          partial: 'public/shared/donation_form_payment_section',
          locals: {
            section: section,
            donation_form_settings: form_settings,
            donation_form: model,
            add_processing_fee_checkbox: form_settings.charge_processing_fee,
            processing_fee:  form_settings.processing_fee_percentage.to_f
          }
        }
    end
    rows << misc_section_rows
    rows
  end

  def submit_section_rows(section)
    rows = []
    display_amount_label = @payment_form_type || form_settings.has_calculated_amount_field
    # Amount label shows too close the payment section. Added a spacer row.
    if display_amount_label && section[:display_name].blank?
      rows << { partial: 'public/shared/spacer_row' }
    end

    rows <<
      {
        partial: 'public/shared/donation_form_submit_section',
        locals: {
          donation_form_settings: form_settings,
          donation_form: model,
          display_amount: display_amount_label,
          section: section
        }
      }
    rows <<
      {
        partial: 'public/shared/form_fields',
        locals: {
          section: section,
          donation_form_settings: form_settings,
          donation_form: model
        }
      }
    rows
  end

  def custom_section_rows(section)
    rows = []
    if section[:displayable]
      rows << section_heading_row(section)
      rows <<
        {
          partial: 'public/shared/form_fields',
          locals: {
            section: section,
            donation_form_settings: form_settings,
            donation_form: model
          }
        }
    end
    rows
  end

  def custom_message_section_rows(section)
    rows = []
    rows <<
      {
        partial: 'public/shared/donation_form_custom_message',
        locals: {
          donation_form_settings: form_settings,
          show_message: form_settings.show_custom_message && form_settings.custom_message.present?
        }
      }
    rows
  end

  def pre_lookup_section_rows(section)
    rows = []
    if model.lookup_enabled && section[:displayable]
      rows <<
        {
          partial: 'public/shared/donation_form_pre_lookup',
          locals: {
            section: section,
            donation_form_settings: form_settings,
            donation_form: model
          }
        }
    end
    rows
  end

  def misc_section_rows
    {
      partial: 'public/shared/donation_form_misc_section',
      locals: {
        donation_form_settings: form_settings,
        donation_form: model
      }
    }
  end
end
