module PageLinkTracking
  class PageLinkTrackingBaseView < ViewModel
    RECENT_PAGE_VISITS_KEY = :rpv

    def is_bot?
      tester = VoightKampff::Test.new(request.user_agent)

      is_bot = true
      if tester.bot?
        bot_pattern = tester.agent["pattern"]
      elsif FacebookIpAddresses.is_facebook?(request.remote_ip)
        bot_pattern = "Facebook IP: #{request.remote_ip}"
      else
        is_bot = false
      end

      # TODO: remove code creating BotDetection records once we can reliably trust that the VoightKampff gem works as it should
      #  we can also change this code to simply "request.bot?"
      if has_page_tracking_feature?
        BotDetection.create(
          bot_pattern: bot_pattern,
          referrer: referrer,
          url: request.url,
          user_agent: request.user_agent,
          bot: is_bot
        )
      end

      is_bot
    end

    def has_page_tracking_feature?
      AccountService.has_feature?(model, Feature::PAGE_TRACKING)
    end

    protected

    def referrer
      request.env.try(:[], 'HTTP_REFERER')
    end

    def service
      @service ||= PageTrackingService.new
    end

    def recent_page_visits
      cookies.encrypted[RECENT_PAGE_VISITS_KEY] ||= []
    end
  end
end