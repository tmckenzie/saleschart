module Sharing
  class AbstractSharingTemplate
    attr_accessor :activity, :share_type

    delegate :share_url, to: :activity

    def initialize(activity, share_type)
      self.activity = activity
      self.share_type = share_type
    end

    def link_icon
      "mobile/social_media/#{share_type}.png"
    end

    def link_icon_alt
      share_type.titleize
    end

    def link_url
      raise NotImplementedError
    end

    def link_attributes
      {
          class: "#{share_type}-share",
          title: "Share on #{link_icon_alt}",
          data: { action: 'share', platform: link_icon_alt},
          onclick: "social_media_share_callback('#{share_url}', '#{share_event}');"
      }.tap do |attributes|
        attributes[:target] = target if target
      end
    end

    protected

    def share_event
      share_event = "#{share_type.upcase}_SHARE"
    end

    def ga_event
      share_event
    end

    def target
      nil
    end
  end
end