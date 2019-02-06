class Sharing::EmailShareTemplate < Sharing::AbstractSharingTemplate
  def initialize(activity)
    super activity, ::Activities::AbstractActivityView::MEDIA_TYPE_EMAIL
  end

  def link_url
    "mailto:?subject=#{ue subject}&body=#{ue body}"
  end

  def link_attributes
    super.merge(title: 'Share via email')
  end

  protected

  def share_event
    MobileFormTrackingService::EMAIL_SHARE_TYPE
  end

  def ga_event
    "emailshare"
  end

  def subject
    activity.email_subject
  end

  def body
    activity.media_message_for(PeerFundraiserActivity::MEDIA_TYPE_EMAIL)
  end

  def ue(string)
    string = URI.escape (string)
    URI.escape string, StringUtil.rfc3986_uri_reserved_chars
  end

end