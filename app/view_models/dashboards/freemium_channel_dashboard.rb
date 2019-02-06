module Dashboards
  class FreemiumChannelDashboard < DashboardView

    def initialize(view)
      @npos = Freemium.the_freemium.account.npos
      @npos = [] if @npos.nil?
      super view
    end

    def total_collected_amount_for_this_month
      ReportCalculation.total_collected_amount(@npos, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_previous_month
      ReportCalculation.total_collected_amount(@npos, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month)
    end

    def total_collected_amount
      ReportCalculation.total_collected_amount(@npos)
    end

    def total_accounts
      @npos.count
    end

    def freemium_filter(params, ability)
      @freemium_filter ||= begin
        attrs = (params[:account_filter] || {}).merge(current_ability: ability)
        AccountFilter.new attrs
      end
    end

    def freemium_accounts_table
      rows = []
      @freemium_filter.freemium_accounts.each do |npo|
        rows << {
            npo: {id: npo.id, name: npo.name, admin_id: npo.admin.try(:id), email: npo.admin.try(:email), last_login: npo.admin.try(:last_sign_in_at)},
            total_collected_amount: ReportCalculation.total_collected_amount(npo)
        }
      end
      rows
    end

  end
end