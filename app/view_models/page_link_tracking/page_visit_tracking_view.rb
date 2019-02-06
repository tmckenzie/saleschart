module PageLinkTracking
  class PageVisitTrackingView < PageLinkTrackingBaseView
    attr_accessor :visitor

    LAST_REFERRING_PAGE_LINK_ID_SESSION_KEY = :last_referring_page_link_id

    # returns redirect params or nil
    def register_visit
      if !is_bot?
        visit = track_visit
        self.visitor = visit.try(:visitor)
        if visit && visit.share_link && params[:vid] != visit.share_link.encoded_id
          share_vid = visit.share_link.encoded_id
          params.merge(vid: share_vid).except(:uid, :sm)
        end
      end
    end

    private

    def last_referring_page_link_id
      session[LAST_REFERRING_PAGE_LINK_ID_SESSION_KEY]
    end

    def last_referring_page_link_id=(page_link_id)
      session[LAST_REFERRING_PAGE_LINK_ID_SESSION_KEY] = page_link_id
    end

    def track_visit
      service.track_visit(
        destination: model,
        user: current_user,
        utm_source: params[:utm_source],
        utm_medium: params[:utm_medium],
        utm_campaign: params[:utm_campaign],
        utm_term: params[:utm_term],
        utm_content: params[:utm_content],
        share_path: request.path,
        current_path: request.fullpath,
        referrer: referrer,
        user_agent: request.user_agent,
        last_referring_page_link_id: last_referring_page_link_id,
        recent_page_visits: recent_page_visits,
        vid: params[:vid],
        uid: params[:uid],
        generate_share_link: options[:generate_share_link]
      ).tap { |visit| store_visit_info(visit) }
    end

    def store_visit_info(visit)
      if visit
        visit_ids = recent_page_visits

        # remove from list if already present and add to end of list
        visit_ids.delete(visit.id)
        visit_ids << visit.id

        # Make sure the list of "recent" links doesn't exceed 10 (an arbitrary pick for a number)
        cookies.encrypted[RECENT_PAGE_VISITS_KEY] = visit_ids.last(10)

        self.last_referring_page_link_id = visit.page_link_id
      end
    end
  end
end