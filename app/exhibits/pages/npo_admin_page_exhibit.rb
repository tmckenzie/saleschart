class Pages::NpoAdminPageExhibit < Pages::AdminPageExhibit
  delegate :card_type, to: :view_model

  def campaign_card(campaign, *)
    Cards::CampaignCardExhibit.new(self, campaign).render_component
  end

  def render_campaign_cards(options={ async: false })
    async = !!options[:async]
    if async
      render_async view.active_campaigns_dashboard_path
    else
      render partial: "dashboard/cards/campaign_cards", campaigns: view_model.campaigns
    end
  end

  def render_keywords_table(options={ async: false })
    async = !!options[:async]
    if async
      render_async view.active_keywords_dashboard_path
    else
      render partial: "dashboard/npo/keywords_table", keywords: view_model.keywords
    end
  end
end