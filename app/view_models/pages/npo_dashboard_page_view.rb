module Pages
  class NpoDashboardPageView < StaticPageView
    def npo
      npo ||= page.account.accountable
    end

    def total_pledged_amount
      ReportCalculation.total_pledged_amount(npo)
    end

    def total_donors
      ReportCalculation.total_donors(npo)
    end

    def total_collected_amount
      ReportCalculation.total_collected_amount(npo)
    end

    def total_offline_amount
      ReportCalculation.total_offline_amount(npo)
    end

    def total_pending_amount
      ReportCalculation.total_pending_amount(npo)
    end

    def total_collected_amount_for_this_month
      ReportCalculation.total_collected_amount(npo, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_previous_month
      ReportCalculation.total_collected_amount(npo, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month)
    end

    def total_subscribers
      ReportCalculation.total_subscribers(npo)
    end

    def total_messages_sent
      ReportCalculation.total_messages_sent(npo)
    end

    def total_messages_sent_this_month
      ReportCalculation.total_messages_sent(npo, Time.now.utc.beginning_of_month)
    end

    def card_type(object)
      if object.is_a?(Campaign)
        if object[:keywords_count] == 1 && object[:keyword_type_id].present?
          KeywordType.find(object[:keyword_type_id]).type
        else
          "campaign"
        end
      end
    end

    def campaigns
      StatisticsService.new.campaign_stats_for_npo(npo, sort_mode: view.params[:sort_mode], filter_mode: view.params[:filter_mode]).paginate(page: view.params[:page])
    end

    def keywords
      per_page = npo.keyword_pagination_count.to_i <= 0 ? CampaignsKeyword.per_page : npo.keyword_pagination_count.to_i
      StatisticsService.new.keyword_stats_for_npo(npo, sort_mode: view.params[:sort_mode], filter_mode: view.params[:filter_mode]).paginate(page: view.params[:page], per_page: per_page)
    end

    def path_for(element_name)
      case element_name
      when DashboardPage::KEYWORDS
        view.active_keywords_dashboard_path
      when DashboardPage::CAMPAIGNS
        view.active_campaigns_dashboard_path
      end
    end

    def transaction_bar_graph_url
      view.data_npo_analytics_path(chart_type: "bar_chart", npo_id: npo.id, year: Date.today.year)
    end

    def transaction_pie_chart_url
      view.data_npo_analytics_path(chart_type: "pie_chart", npo_id: npo.id, year: Date.today.year)
    end
  end
end

