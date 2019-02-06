class SocialGivingActivity < Activities::AbstractActivityView
  attr_reader :activity_config
  delegate :campaigns_keyword, to: :activity_config

  def initialize(campaigns_keyword = nil)
    @activity_config = if campaigns_keyword.present?
      Forms::ApiFundraisingConfiguration.find_by_campaigns_keyword campaigns_keyword
    else
      Forms::ApiFundraisingConfiguration.new
    end
  end

  def set_activity_attributes(params)
    activity_config.set_attributes(
        params.merge(
            activity_type: KeywordType.fundraising_social_giving.name,
            shortcode_id: Shortcode.for_social_giving.first.id
        )
    )
  end

  def shortcode
    campaigns_keyword.keyword.shortcode
  end

  def call_center_script
    campaigns_keyword.call_center_script
  end

  def type_string
    activity_config.try(:keyword).try(:shortcode).try(:keyword_type).try(:name) || KeywordType::FUNDRAISING_SOCIAL_GIVING
  end

  def keyword_string
    activity_config.try(:keyword).try(:keyword_string)
  end

  def shortcode_string
    activity_config.try(:keyword).try(:shortcode).try(:shortcode_string)
  end

  def share_url
    Rails.application.routes.url_helpers.short_social_giving_url(campaigns_keyword.encoded_id, :host => CONFIG[:application][:short_host])
  end

  def npo
    campaigns_keyword.campaign.npo
  end

  def personal_call_to_action
    campaigns_keyword.default_custom_call_to_action
  end

  def campaign_call_to_action
    campaigns_keyword.call_to_action
  end

  def donation_url
    Rails.application.routes.url_helpers.public_social_url(campaigns_keyword)
  end
end
