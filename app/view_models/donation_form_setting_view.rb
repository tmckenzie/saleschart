class DonationFormSettingView

  ATTRIBUTES =
      [
          :bg_url,
          :logo_url,
          :display_logo,
          :charge_processing_fee,
          :processing_fee_default_opt_in,
          *DonationFormSetting.all_shared_setting_field_names.map(&:to_sym),
          :no_suggestion,
          :suggested_amount_1,
          :suggested_amount_2,
          :suggested_amount_3,
          :show_custom_message,
          :custom_message,
          :default_donation_amount,
          :display_form_fields,
          :required_form_fields,
          :display_frequency,
          :donation_button_text,
          :body_sections,
          :popup_sections,
          :sub_type,
          :has_calculated_amount_field,
          :confirmation_page,
          :display_fundraiser_registration_option,
          :accept_donor_registration,
          :require_captcha,
          :npo,
          :credit_cards_accepted,
          :campaigns_keyword
      ]

  USER_VARIABLE_REPLACEMENT_MAPPING =
      {
          Percent: "[" + SharedSettingType::PROCESSING_FEE_PERCENTAGE + "]%",
      }

  attr_accessor *ATTRIBUTES, :disable_submit

  def initialize(attributes = {})
    set_attributes(attributes)
    @display_form_fields = {}
    @required_form_fields = {}
    @body_sections = {}
    @popup_sections = {}
  end

  def set_attributes(attributes)
    if attributes
      ATTRIBUTES.each do |attribute|
        next if attributes[attribute].nil?
        send("#{attribute}=", attributes[attribute])
      end
    end
  end

  def self.load_from(donation_form_setting)
    params = {
        campaigns_keyword: donation_form_setting.campaigns_keyword,
        npo: donation_form_setting.campaigns_keyword.npo,
        display_logo: donation_form_setting.display_logo,
        no_suggestion: donation_form_setting.no_suggestion,
        suggested_amount_1: donation_form_setting.suggested_amount_1,
        suggested_amount_2: donation_form_setting.suggested_amount_2,
        suggested_amount_3: donation_form_setting.suggested_amount_3,
        show_custom_message: donation_form_setting.show_custom_message,
        custom_message: donation_form_setting.custom_message,
        default_donation_amount: donation_form_setting.default_donation_amount,
        display_frequency: donation_form_setting.display_frequency,
        donation_button_text: donation_form_setting.donation_button_text,
        sub_type: donation_form_setting.sub_type,
        has_calculated_amount_field: donation_form_setting.has_calculated_amount_field?,
        confirmation_page: donation_form_setting.confirmation_page,
        display_fundraiser_registration_option: donation_form_setting.display_fundraiser_registration_option?,
        accept_donor_registration: donation_form_setting.accept_donor_registration,
        require_captcha: donation_form_setting.require_captcha,
        credit_cards_accepted: donation_form_setting.credit_cards_accepted
    }
    DonationFormSetting.all_shared_setting_field_names.map(&:to_sym).each do |field|
      params[field] = donation_form_setting.send(field) if !params.key?(field)
    end
    if donation_form_setting.brand_logo.present?
      params[:logo_url] = donation_form_setting.brand_logo.url
    end
    params[:bg_url] = donation_form_setting.background_image.url if donation_form_setting.background_image.present?

    config = DonationFormSettingView.new(params)
    config.setup_custom_field_methods(donation_form_setting)
    config.setup_standard_field_methods(donation_form_setting)
    config.setup_popup_sections(donation_form_setting)
    config.setup_body_sections(donation_form_setting)
    config
  end

  def self.load_preview_from(donation_form_setting)
    config = DonationFormSettingView.load_from(donation_form_setting)
    config.disable_submit = true
    if donation_form_setting.tmp_attrs.present?
      tmp_attrs = YAML.load(donation_form_setting.tmp_attrs).with_indifferent_access.except(*DonationFormSetting.all_shared_setting_field_names)
      custom_fields = tmp_attrs['custom_form_fields']
      std_fields = tmp_attrs['custom_form_std_fields']
      tmp_sections = tmp_attrs['donation_form_sections']
      tmp_attrs = normalize_tmp_attrs(tmp_attrs) # normalize string values to their respective db types
      config.set_attributes(tmp_attrs)

      if custom_fields.present?
        custom_fields.each do |cf_id, cf_val|
          config.display_form_fields[cf_id.to_s] = (cf_val == 'Show' || cf_val == 'Required') ? true : false
          config.required_form_fields[cf_id.to_s] = (cf_val == 'Required') ? true : false
        end
      end
      if std_fields.present?
        std_fields.each do |cf_id, cf_val|
          config.display_form_fields[cf_id.to_s] = (cf_val == 'Show' || cf_val == 'Required') ? true : false
          config.required_form_fields[cf_id.to_s] = (cf_val == 'Required') ? true : false
        end
      end
      if tmp_sections.present?
        tmp_sections.each do |section_name, details|
          if config.body_sections[section_name].present?
            config.body_sections[section_name][:display_name] = details['display_name']
            config.body_sections[section_name][:display] = details['display'] == 'false' ? false : true
          end
        end
      end
    end
    config
  end

  def self.normalize_tmp_attrs(config)
    return if config.blank?
    config[:no_suggestion] = config[:no_suggestion] == 'false' ? false : true
    config[:display_logo] = config[:display_logo] == 'false' ? false : true
    config[:show_custom_message] = config[:show_custom_message] == 'false' ? false : true
    config[:suggested_amount_1] = Float(config[:suggested_amount_1]) if StringUtil.numeric?(config[:suggested_amount_1])
    config[:suggested_amount_2] = Float(config[:suggested_amount_2]) if StringUtil.numeric?(config[:suggested_amount_2])
    config[:suggested_amount_3] = Float(config[:suggested_amount_3]) if StringUtil.numeric?(config[:suggested_amount_3])
    config[:default_donation_amount] = Float(config[:default_donation_amount]) if StringUtil.numeric?(config[:default_donation_amount])
    config[:display_frequency] = config[:display_frequency] == 'false' ? false : true
    config[:require_captcha] = (config[:require_captcha].nil? || config[:require_captcha] == 'false') ? false : true
    config
  end

  def setup_custom_field_methods(donation_form_setting)
    donation_form_setting.custom_fields.each do |m|
      @display_form_fields[m.id.to_s] = m.display
      @required_form_fields[m.id.to_s] = m.required?
    end
  end

  def setup_standard_field_methods(donation_form_setting)
    donation_form_setting.standard_fields.each do |m|
      @display_form_fields[m.id.to_s] = m.display
      @required_form_fields[m.id.to_s] = m.required?
    end
  end

  def setup_body_sections(donation_form_setting)
    @body_sections = setup_sections_from(donation_form_setting.sections)
  end

  def setup_popup_sections(donation_form_setting)
    @popup_sections = setup_sections_from(donation_form_setting.popup_sections)
  end

  def setup_sections_from(form_sections)
    sections = {}
    if form_sections.present?
      form_sections.each do |m|
        sections[m.section_name] = {id: m.id, display_name: m.display_name, base_section: m.base_section, display: m.display, displayable: section_displayable(m)}
      end
    end
    sections
  end

  def display(field_id)
    m = @display_form_fields[field_id.to_s]
    r = @required_form_fields[field_id.to_s]
    r || m
  end

  def section_displayable(section)
    self.accept_donor_registration || section.displayable_custom_fields.count > 0
  end

  def donation_button_text
    @donation_button_text.present? ? @donation_button_text : DonationFormSetting::DEFAULT_DONATION_BUTTON_TEXT
  end

  def processing_fee_text
    value = @processing_fee_text.present? ? @processing_fee_text : SharedSettingType.find_by_name(SharedSettingType::PROCESSING_FEE_TEXT).default
    StringUtil.replace_template_var(replace_user_variables(value), self)
  end

  def custom_message_html
    StringUtil.text_to_html(custom_message)
  end

  def require_captcha?
    @npo.has_donation_form_require_captcha_feature? || (self.require_captcha.present? && self.require_captcha)
  end

  def logo_url
    @logo_url.present? ? @logo_url : @brand_logo.try(:url)
  end

  def bg_url
    @bg_url.present? ? @bg_url : @background_image.try(:url)
  end

  def has_paypal_payment_option?
    @has_paypal_payment_option ||=
        (@npo.has_paypal? && payment_methods.include?(PaymentProcessor::PAYPAL_PROCESSOR))
  end

  def paypal_supports_recurring?
    @paypal_supports_recurring ||= @npo.paypal_payment_processor.try(:supports_recurring?)
  end

  def recurring_frequency_from(field_value)
    if field_value.present?
      field_value
    elsif self.payment_frequencies.present? && self.payment_default_frequency.present?
      self.payment_default_frequency.gsub(' ', '_')
    end
  end

  def replace_user_variables(str)
    result_str = str
    USER_VARIABLE_REPLACEMENT_MAPPING.each do |match_key, match_value|
      result_str = result_str.gsub(/\[#{match_key}\]/i, "#{match_value}")
    end
    result_str
  end

  def facebook_share_title
    campaigns_keyword.campaign.name
  end

  def facebook_share_description
    campaigns_keyword.facebook_share_message
  end

  def facebook_share_image
    campaigns_keyword.facebook_share_image.try(:url, :large) || brand_logo.try(:url, :large)
  end

  def facebook_share_url
    URI.parse("#{CONFIG[:application][:email_host]}/f/#{campaigns_keyword.encoded_id}/n").to_s
  end

  def processing_fee_user_choice(user_value)
    if user_value.present?
      user_value.to_f != 0.0
    else
      processing_fee_default_opt_in
    end
  end
end
