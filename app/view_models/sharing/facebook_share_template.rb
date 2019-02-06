class Sharing::FacebookShareTemplate < Sharing::AbstractSharingTemplate
  def initialize(activity)
    super activity, ::Activities::AbstractActivityView::MEDIA_TYPE_FACEBOOK
  end

  def link_url
    "https://www.facebook.com/sharer/sharer.php?u=#{activity.share_url}"
  end

  protected

  def share_event
    MobileFormTrackingService::FACEBOOK_SHARE_TYPE
  end

  def target
    "_blank"
  end
end
