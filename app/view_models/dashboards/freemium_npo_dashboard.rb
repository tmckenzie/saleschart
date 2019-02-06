module Dashboards
  class FreemiumNpoDashboard < DashboardView
    attr_reader :npo, :online_giving_ck

    def initialize(view, npo_user)
      @npo = npo_user.npo
      setup_online_page
      super view
    end

    def setup_online_page
      online_giving= OnlineGift.where(npo_id: @npo.id).first
      if online_giving.nil?
        @online_giving_ck = OnlineGift.create_with_dependencies_for(@npo).campaigns_keyword
      else
        @online_giving_ck = online_giving.campaigns_keyword
      end
    end

    def total_pledged_amount
      ReportCalculation.total_pledged_amount(@npo)
    end

    def total_donors
      ReportCalculation.total_donors(@npo)
    end

    def total_collected_amount
      ReportCalculation.total_collected_amount(@npo)
    end

    def total_collected_amount_for_this_month
      ReportCalculation.total_collected_amount(@npo, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_previous_month
      ReportCalculation.total_collected_amount(@npo, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month)
    end

    def total_subscribers
      ReportCalculation.total_subscribers(@npo)
    end

    def total_messages_sent
      ReportCalculation.total_messages_sent(@npo)
    end

    def total_messages_sent_this_month
      ReportCalculation.total_messages_sent(@npo, Time.now.utc.beginning_of_month)
    end
  end
end