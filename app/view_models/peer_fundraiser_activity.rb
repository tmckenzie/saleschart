class PeerFundraiserActivity < Activities::AbstractActivityView
  include PeerFundraiserHelper

  attr_accessor :peer_fundraiser
  attr_accessor :activity_config
  attr_accessor :current_user

  delegate :campaigns_keyword, to: :activity_config
  delegate :facebook_message_element,
           :twitter_message_element,
           :text_message_element,
           :email_message_element,
       to: :crowdfunding_page

  delegate :content, to: :facebook_message_element, prefix: :facebook
  delegate :content, to: :twitter_message_element, prefix: :twitter
  delegate :content, to: :text_message_element, prefix: :text
  delegate :subject,
           :body,
       to: :email_message_element,
   prefix: :email

  alias_method :email_content, :email_body

  def initialize(campaigns_keyword = nil, peer_fundraiser = nil, set_ck = false)
    self.activity_config = if campaigns_keyword.present?
                         Forms::ApiFundraisingConfiguration.find_by_campaigns_keyword campaigns_keyword
                       else
                         Forms::ApiFundraisingConfiguration.new({:peer_fundraiser_subtype => true, goal_type: SharedSettingType.find_by_name(SharedSettingType::GOAL_TYPE).default}, set_ck)
                       end
    self.peer_fundraiser = peer_fundraiser
  end

  def set_activity_attributes(params)
    shortcode_id = params[:shortcode_id].present? ?  params[:shortcode_id] : Shortcode.for_social_giving.first.id
    activity_config.set_attributes(
        params.merge(
            activity_type: KeywordType.fundraising_social_giving.name,
            shortcode_id: shortcode_id,
            :peer_fundraiser_subtype => true
        )
    )
  end

  def update_child_keywords(old_keyword, new_keyword)
    old_keyword_length = old_keyword.length
    peer_fundraisers = PeerFundraiser.where(campaigns_keyword_id: campaigns_keyword.id).to_a
    peer_fundraisers.each do |pf|
      unless pf.personal_keyword.nil?
        ks = new_keyword + pf.personal_keyword.byteslice(old_keyword_length, pf.personal_keyword.length)
        pf.update_attributes(personal_keyword: ks) if Keyword.find_by_keyword_string_and_shortcode_id(ks, Shortcode.for_social_giving.first.id).nil?
      end
    end
  end

  def fundraisers_filter_view
    @fundraisers_filter_view ||=
      begin
        fundraiser_filter = FundraiserFilter.new(campaigns_keyword_id: campaigns_keyword.try(:id))
        Filter::FilterView.build_search_filter(fundraiser_filter, current_user)
      end
  end

  def fundraiser_status_filters(current_filters)
    fundraisers_filter_view.status_filters_from(current_filters)
  end

  def keyword_string
    activity_config.try(:keyword).try(:keyword_string)
  end

  def type_string
    KeywordType::VOLUNTEER_FUNDRAISING
  end

  def shortcode_string
    activity_config.try(:keyword).try(:shortcode).try(:shortcode_string)
  end

  def share_url
    fundraising_url(peer_fundraiser)
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

  def npo
    campaigns_keyword.campaign.npo
  end

  def root_page_url
    peer_fundraising_home_page_url(campaigns_keyword.root_fundraiser)
  end

  def fundraising_name
    peer_fundraiser.try(:fundraising_name) || ""
  end

  def categories
    campaigns_keyword.categories
  end

  def peer_fundraiser_teams
    campaigns_keyword.peer_fundraiser_teams.order('created_at desc')
  end

  private

  def crowdfunding_page
    @crowdfunding_page ||= campaigns_keyword.find_or_create_crowdfunding_page
  end
end
