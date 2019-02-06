class DonationFormSettingExhibit < Exhibit
  attr_reader :section_titles

  def section_rows_to_render(form)
    @current_npo = context.current_npo
    @form = form
    @section_titles = []

    rows = []
    model.configurable_sections('popup').each do |section|
      section_rendering_method = "#{section.section_name}_section_rows".to_sym
      if respond_to?(section_rendering_method)
        rows += send(section_rendering_method, section)
      end
    end
    model.configurable_sections.each do |section|
      section_rendering_method = "#{section.section_name}_section_rows".to_sym
      if respond_to?(section_rendering_method)
        rows += send(section_rendering_method, section)
      else
        rows += custom_section_rows(section)
      end
      rows
    end
    rows
  end

  def amount_section_rows(section)
    can_config_suggested_amounts = !model.has_calculated_amount_field?
    section_title = section.title
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/amount_section',
        locals: { donation_form_setting: model, f: @form, section: section, section_title: section_title, can_config_suggested_amounts: can_config_suggested_amounts }
      }
    ]
  end

  def frequency_section_rows(section)
    section_title = section.title
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/frequency_section',
        locals: {
          donation_form_setting: model,
          f: @form,
          section: section,
          section_title: section_title
        }
      }
    ]
  end

  def payment_section_rows(section)
    section_title = section.title(@current_npo)
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/payment_section',
        locals: {
          donation_form_setting: model,
          form_builder: @form, section: section,
          section_title: section_title,
          allow_charge_later: @current_npo.has_donation_form_charge_later_feature? && @current_npo.check_active_payment_processors_for(:supports_charge_later?),
          processing_fee_text_tooltip: context.donation_form_processing_fee_text_tooltip,
        }
      }
    ]
  end

  def custom_message_section_rows(section)
    section_title = section.title
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/custom_message_section',
        locals: {
          donation_form_setting: model,
          f: @form,
          section: section,
          section_title: section_title,
          section_id: 'panel_custom_msg_section',
          tooltip: context.mobile_pledging_keyword_custom_message_tooltip,
          show_rich_text_editor: false,
        }
      }
    ]
  end

  def submit_section_rows(section)
    section_title = section.title
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/submit_section',
        locals: {
          donation_form_setting: model,
          f: @form, section: section,
          section_title: section_title,
          allow_captcha_config: !@current_npo.has_donation_form_require_captcha_feature?,
          allow_callback_url_config: context.mc_admin?,
          allow_fundraiser_signup_option_config: !is_a?(FundraiserSignUpFormSettingExhibit) && context.mc_admin? && model.campaigns_keyword.peer_fundraising?,
          allow_email_receipt_config: !is_a?(FundraiserSignUpFormSettingExhibit) && !@current_npo.owned_by_freemium? && @current_npo.has_tax_receipt_feature?
        }
      }
    ]
  end

  def pre_lookup_section_rows(section)
    [
      {
        partial: 'donation_form_settings/pre_lookup_section',
        locals: {
          donation_form_setting: model,
          f: @form,
          section: section,
          section_title: section.title
        }
      }
    ]
  end

  def custom_section_rows(section)
    section_title = section.title
    icon = 'fa-ticket' if section.ticketing_template?
    @section_titles << [section_title, section.id]
    [
      {
        partial: 'donation_form_settings/custom_section',
        locals: {
          donation_form_setting: model,
          section: section,
          section_title: section_title,
          icon: icon
        }
      }
    ]
  end
end
