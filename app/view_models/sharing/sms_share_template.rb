class Sharing::SmsShareTemplate < Sharing::AbstractSharingTemplate
  def initialize(activity)
    super activity, ::Activities::AbstractActivityView::MEDIA_TYPE_TEXT
  end

  def link_url
    "sms:?&body=#{body}"
  end

  def link_icon
    "mobile/social_media/text.png"
  end

  def link_icon_alt
    "SMS"
  end

  def link_attributes
    {
      id: 'sms-share',
      title: 'Share via Text SMS',
      data: { action: 'share', platform: 'SMS'},
      onclick: super[:onclick]
    }
  end

  private

  def share_event
    MobileFormTrackingService::SMS_SHARE_TYPE
  end

  def body
    # Make sure to encode url so that they become properly shareable on iPhone and other mobile devices.
    str = activity.media_message_for(PeerFundraiserActivity::MEDIA_TYPE_TEXT, true) || ""
    str.gsub('&', 'and')
  end
end
