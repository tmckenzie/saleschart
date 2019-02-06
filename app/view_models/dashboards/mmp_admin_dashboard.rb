module Dashboards
  class MMPAdminDashboard < DashboardView

    def initialize(view, user = nil)
      @user = user
      super view
    end

    def total_subscribers
      ReportCalculation.total_subscribers
    end

    def total_messages_sent
      ReportCalculation.total_messages_sent
    end

    def total_messages_sent_this_month
      ReportCalculation.total_messages_sent(nil, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_this_month
      ReportCalculation.total_collected_amount(nil, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_previous_month
      ReportCalculation.total_collected_amount(nil, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month)
    end

    def total_collected_amount
      ReportCalculation.total_collected_amount
    end

    def total_accounts
      Npo.count
    end

    def operations_admin?
      @user.present? ? @user.operations_admin? : false
    end
  end
end