module Activities
  class ActivityView < ViewModel
    delegate :id,
             :active?,
             :auction_subtype?,
             :keyword_type,
             :shortcode_string,
             :keyword_string,
             :display_status,
             :subscriber_count,
             :collected_donation_count,
             :amount_raised,
             :amount_pledged,
             :offline_raised,
             :amount_pending,
             :created_at,
             :peer_fundraising?,
             :fundraising_keyword?,
             :communication_keyword?,
             :legacy_keyword?,
             :fundraising_mobile_pledging?,
             :root_fundraiser,
             :campaign,
             :npo,
             :campaign_event,
         to: :model

    def self.for_campaign(campaign, view)
      activities = StatisticsService.new.keyword_stats_for_campaign(campaign)
      ViewModelCollection.new(view: view, collection: activities, view_model_class: self)
    end

    def edit_path
      edit_activity_path(id, back_to_params)
    end

    def event_dashboard_path
       event_dashboard_campaign_campaign_event_path(campaign: campaign, id: campaign_event.id)
    end

    def name
      if auction_subtype?
        KeywordType::AUCTION
      else
        keyword_type.type.titleize
      end
    end

    def keyword_description
      "#{keyword_string} (on #{shortcode_string})"
    end

    def subscribers
      count_for_display(subscriber_count)
    end

    def gift_count
      count_for_display(collected_donation_count)
    end

    def average_gift
      if amount_raised.present?
        avg_amount = collected_donation_count > 0 ? (amount_raised / collected_donation_count) : 0
      end
      amount_for_display avg_amount
    end

    def pledged
      amount_for_display amount_pledged
    end

    def offline
      amount_for_display offline_raised
    end

    def pending
      amount_for_display amount_pending
    end

    def collected
      amount_for_display amount_raised
    end

    def date
      created_at.to_date.to_s
    end

    def back_to_params
      {
        referrer: "campaign",
        back_path: campaign_keywords_path(campaign),
      }
    end

    def actions
      actions = []
      if !communication_keyword? && !legacy_keyword?
        actions << {
          label: "View Transactions",
          path: transactions_path(
            back_to_params.merge(
              transaction_filter: Filter::TransactionFilterView.transaction_paid_filter.merge(campaigns_keyword_id: id, campaign_id: campaign.try(:id))
            )
          ),
          icon_class: "fa-list"
        }
      end

      if npo.has_allow_people_search_feature?
        actions << {
          label: "View Audience",
          path: peoples_path(
            back_to_params.merge(people_filter: { campaigns_keyword_id: id })
          ),
          icon_class: "fa-user"
        }
      end

      if fundraising_mobile_pledging?
        actions << {
          label: "Enter Offline Donation",
          path: edit_activity_path(id, back_to_params.merge(section: 'offline-form')),
          icon_class: "fa-money"
        }
      end

      if peer_fundraising?
        actions << {
          label: "Preview Fundraising Page",
          path: peer_fundraising_home_page_url(root_fundraiser),
          icon_class: "fa-eye",
          target: "_blank"
        }
        actions << {
          label: "Enter Offline Donation",
          path: edit_activity_path(id, back_to_params.merge(section: 'offline-form')),
          icon_class: "fa-money"
        }
        actions << {
          label: "Manage Teams",
          path: edit_activity_path(id, back_to_params.merge(section: 'my-teams')),
          icon_class: "fa-user-circle-o"
        }
        actions << {
          label: "Edit Fundraising Page",
          path: edit_path,
          icon_class: "fa-pencil-square-o"
        }

      elsif auction_subtype?
        actions << {
          label: "Edit Keyword",
          path: edit_path,
          icon_class: "fa-pencil-square-o"
        }
        actions << {
          label: "Login to Handbid",
          path: "https://events.handbid.com/",
          icon_class: "fa-sign-out",
          target: "_blank"
        }
      else
        actions << {
          label: "Edit Keyword",
          path: edit_path,
          icon_class: "fa-pencil-square-o"
        }
      end

      actions
    end

    def forms
      if fundraising_keyword?
        model.available_forms.map do |form|
          Activities::FormView.new(view: view, model: form, activity: self)
        end
      else
        []
      end
    end
  end
end