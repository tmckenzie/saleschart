class PeerFundraiserSettingView
  ATTRIBUTES =
      [
          :campaigns_keyword,
          :fundraising_inspirational_img_url,
          :fundraising_inspirational_img_file_name,
          :seed_page_profile_img_url,
          :seed_page_profile_img_file_name,
          :background_img_url,
          :background_img_file_name,
          :organization_img_url,
          :organization_img_file_name,
          :crowdfunding_call_to_action,
          :accent_color,
          :organization_goal,
          :organization_summary,
          :display_seed_page_profile_img,
          :display_background_img,
          :default_fundraising_goal,
          :become_fundraiser_button_text,
          :signup_form_id,
          :donation_form_id,
          :display_login,
          :display_progress_bar,
          :display_donors,
          :can_join_team,
          :facebook_share_img,
          :display_fundraiser_button,
          :custom_form_button_text
      ]

  attr_accessor *ATTRIBUTES

  def initialize(attributes = {})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    if attributes
      ATTRIBUTES.each do |attribute|
        next if attributes[attribute].nil?
        send("#{attribute}=", attributes[attribute])
      end
    end
  end

  def self.load_from(peer_fundraiser_setting)
    params = {
        campaigns_keyword: peer_fundraiser_setting.campaigns_keyword,
        fundraising_inspirational_img_file_name: peer_fundraiser_setting.fundraising_inspirational_img_file_name,
        seed_page_profile_img_file_name: peer_fundraiser_setting.seed_page_profile_img_file_name,
        organization_img_file_name: peer_fundraiser_setting.organization_img_file_name,
        crowdfunding_call_to_action: peer_fundraiser_setting.crowdfunding_call_to_action,
        accent_color: peer_fundraiser_setting.accent_color,
        organization_goal: peer_fundraiser_setting.organization_goal,
        organization_summary: organization_summary(peer_fundraiser_setting),
        display_seed_page_profile_img: peer_fundraiser_setting.display_seed_page_profile_img,
        display_background_img: peer_fundraiser_setting.display_background_img,
        default_fundraising_goal: peer_fundraiser_setting.default_fundraising_goal,
        become_fundraiser_button_text: peer_fundraiser_setting.become_fundraiser_button_text,
        signup_form_id: peer_fundraiser_setting.signup_form_id,
        donation_form_id: peer_fundraiser_setting.donation_form_id,
        display_login: peer_fundraiser_setting.display_login,
        display_progress_bar: peer_fundraiser_setting.display_progress_bar,
        display_donors: peer_fundraiser_setting.display_donors,
        can_join_team: peer_fundraiser_setting.peer_fundraiser_team_setting.allow_team_participation,
        display_fundraiser_button: peer_fundraiser_setting.display_fundraiser_button,
        custom_form_button_text: peer_fundraiser_setting.custom_form_button_text
    }

    params[:fundraising_inspirational_img_url] = peer_fundraiser_setting.fundraising_inspirational_img.url if peer_fundraiser_setting.fundraising_inspirational_img_file_name.present?
    params[:seed_page_profile_img_url] = peer_fundraiser_setting.seed_page_profile_img.url if peer_fundraiser_setting.seed_page_profile_img_file_name.present?
    params[:organization_img_url] = peer_fundraiser_setting.organization_img.url(:large) if peer_fundraiser_setting.organization_img_file_name.present?
    params[:background_img_url] = peer_fundraiser_setting.background_img.url if peer_fundraiser_setting.background_img_file_name.present?

    config = PeerFundraiserSettingView.new(params)
    config
  end

  def self.organization_summary(peer_fundraiser_setting)
    org_summary = peer_fundraiser_setting.organization_summary
    if org_summary.nil?
      org_summary = SharedSetting.setting_value_for(peer_fundraiser_setting.campaigns_keyword.campaign.npo,  SharedSettingType::ORG_SUMMARY)
    end
    org_summary
  end

  def self.load_from_preview(peer_fundraiser_setting)
    config = PeerFundraiserSettingView.load_from(peer_fundraiser_setting)
    if peer_fundraiser_setting.tmp_attrs.present?
      tmp_attrs = YAML.load(peer_fundraiser_setting.tmp_attrs)
      tmp_attrs = tmp_attrs.with_indifferent_access
      tmp_attrs = normalize_tmp_attrs(tmp_attrs) # normalize string values to their respective db types
      config.set_attributes(tmp_attrs)
      if peer_fundraiser_setting.tmp_fundraising_inspirational_img_file_name.present?
        config.fundraising_inspirational_img_url = peer_fundraiser_setting.tmp_fundraising_inspirational_img.url
        config.fundraising_inspirational_img_file_name = peer_fundraiser_setting.tmp_fundraising_inspirational_img_file_name
      end
      if peer_fundraiser_setting.tmp_seed_page_profile_img_file_name.present?
        config.seed_page_profile_img_url = peer_fundraiser_setting.tmp_seed_page_profile_img.url
        config.seed_page_profile_img_file_name = peer_fundraiser_setting.tmp_seed_page_profile_img_file_name
      end

      if peer_fundraiser_setting.tmp_organization_img_file_name.present?
        config.organization_img_url = peer_fundraiser_setting.tmp_organization_img.url
        config.organization_img_file_name = peer_fundraiser_setting.tmp_organization_img_file_name
      end

      if peer_fundraiser_setting.tmp_background_img_file_name.present?
        config.background_img_url = peer_fundraiser_setting.tmp_background_img.url
        config.background_img_file_name = peer_fundraiser_setting.tmp_background_img_file_name
      end

    end
    config
  end

  def self.normalize_tmp_attrs(config)
    return if config.blank?
    config[:display_seed_page_profile_img] = config[:display_seed_page_profile_img] == 'false' ? false : true
    config[:display_background_img] = config[:display_background_img] == 'false' ? false : true
    config[:display_login] = config[:display_login] == 'false' ? false : true
    config[:display_progress_bar] = config[:display_progress_bar] == 'false' ? false : true
    config[:display_donors] = config[:display_donors] == 'false' ? false : true
    config
  end

  def default_fundraising_goal
    @default_fundraising_goal.present? ? @default_fundraising_goal : DonationFormSetting::DEFAULT_FUNDRAISING_GOAL
  end

  def become_fundraiser_button_text
    @become_fundraiser_button_text.present? ? @become_fundraiser_button_text : PeerFundraiserSetting::DEFAULT_BECOME_PEERFUNDRAISER_BUTTON_TEXT
  end

  def custom_form_button_text
    @custom_form_button_text.present? ? @custom_form_button_text : @campaigns_keyword.default_form.nonpayment_type? ? PeerFundraiserSetting::DEFAULT_MEMBERSHIP_FORM_BUTTON_TEXT : PeerFundraiserSetting::DEFAULT_FORM_BUTTON_TEXT
  end

  def display_organization?
    organization_img_file_name.present? || organization_summary.present?
  end

  def organization_summary_html
    StringUtil.text_to_html(organization_summary)
  end

  def hide_donor_wall_amount
    campaigns_keyword.campaign.npo.has_hide_donor_wall_amount_feature?
  end
end
