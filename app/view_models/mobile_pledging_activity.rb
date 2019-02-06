class MobilePledgingActivity < Activities::AbstractActivityView
  attr_accessor :activity_config
  delegate :campaigns_keyword, to: :activity_config

  def initialize(campaigns_keyword=nil, set_ck = false)
    self.activity_config = if campaigns_keyword.present?
      Forms::ApiFundraisingConfiguration.find_by_campaigns_keyword(campaigns_keyword)
    else
      Forms::ApiFundraisingConfiguration.new({}, set_ck)
    end
  end

  def set_activity_attributes(params)
    activity_config.set_attributes(
        params.reverse_merge(
            activity_type: KeywordType.fundraising_mobile_pledging.name,
            shortcode_id: Shortcode.for_mobile_pledging.first.id
        )
    )

  end

  def sub_type=(sub_type)
    activity_config.sub_type = sub_type
  end

  def form_type=(form_type)
    activity_config.form_type = form_type
  end

  def form_name=(form_name)
    activity_config.form_name = form_name
  end

  def shortcode
    campaigns_keyword.keyword.try(:shortcode)
  end

  def call_center_script
    campaigns_keyword.try(:call_center_script)
  end

  def type_string
    activity_config.try(:keyword).try(:shortcode).try(:keyword_type).try(:name) || KeywordType::FUNDRAISING_MOBILE_PLEDGING
  end

  def keyword_string
    activity_config.try(:keyword).try(:keyword_string)
  end

  def shortcode_string
    activity_config.try(:keyword).try(:shortcode).try(:shortcode_string)
  end

  def share_url
    Rails.application.routes.url_helpers.new_short_mobile_pledging_url(campaigns_keyword.encoded_id, :host => CONFIG[:application][:short_host])
  end
  alias_method :root_page_url, :share_url

  def npo
    campaigns_keyword.try(:npo)
  end

  def twitter_content
    campaigns_keyword.try(:twitter_share_message)
  end

  def facebook_content
    campaigns_keyword.try(:facebook_share_message)
  end
end