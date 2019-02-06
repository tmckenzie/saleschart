module PageLinkTracking
  class PageConversionTrackingView < PageLinkTrackingBaseView
    def register_conversion
      if !is_bot?
        service.track_conversion(
          model,
          recent_page_visits,
          current_user
        )
      end
    end
  end
end