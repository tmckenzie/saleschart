class Cards::CampaignCardExhibit < Cards::CardExhibit
  alias_method :campaign, :model
  delegate :view_model, to: :parent_builder

  def card_type
    parent_builder.card_type(campaign)
  end

  def card_partial
    if campaign.keywords_count == 1
      "dashboard/cards/#{card_type}_card"
    else
      "dashboard/cards/campaign_card"
    end
  end

  def average_donation
    average = if total_donation_count > 0
       (total_amount_raised / total_donation_count).round
    else
      0
    end
    view.number_to_currency(average, precision: 0)
  end

  def render_component
    render partial: card_partial, campaign: campaign, parent_builder: parent_builder do
      progress = if (campaign.total_fundraising_goal.to_f != 0)
        [3, [(total_amount_raised.to_f / campaign.total_fundraising_goal.to_f) * 100, 100].min].max
      else
        3
      end
      define Cards::CardExhibit::CARD_PROGRESS_BLOCK, progress: progress
      define :card_progress_total, total: view.number_to_currency(total_amount_raised, precision: 0)
      define :card_progress_goal, goal: view.number_to_currency(campaign.total_fundraising_goal, precision: 0)
      define Cards::CardExhibit::CARD_TITLE_BLOCK, title: campaign.name
      define :card_donation_summary, donation_count: view.number_with_delimiter(total_donation_count), average_donation: average_donation
      define Cards::CardExhibit::CARD_STATUS_BLOCK, settings_path: view.edit_campaign_path(campaign.id)
    end
  end

  private

  def total_donation_count
    offline_donation_count = includes_offline_totals? ? campaign.offline_donation_count.to_i : 0
    campaign.collected_donation_count.to_i + offline_donation_count + campaign.pending_donation_count.to_i - campaign.refunded_donation_count.to_i
  end

  def total_amount_raised
    offline_donation_total = includes_offline_totals? ? campaign.offline_raised.to_f : 0
    campaign.amount_raised.to_f + offline_donation_total + campaign.amount_pending.to_f
  end

  def includes_offline_totals?
    campaign.npo.donations_totals_include_offline
  end
end
