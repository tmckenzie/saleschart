class Sharing::TwitterShareTemplate < Sharing::AbstractSharingTemplate
  def initialize(activity)
    super activity, Activities::AbstractActivityView::MEDIA_TYPE_TWITTER
  end

  def link_url
    "https://twitter.com/share?url=/&text=#{body}"
  end

  private

  def share_event
    MobileFormTrackingService::TWITTER_SHARE_TYPE
  end

  def body
    message = activity.media_message_for(Activities::AbstractActivityView::MEDIA_TYPE_TWITTER) || ""
    URI.encode_www_form_component(message)
  end

  def target
    "_blank"
  end
end