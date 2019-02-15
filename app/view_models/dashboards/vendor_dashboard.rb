module Dashboards
  class VendorDashboard < DashboardView
    attr_reader :vendor
    def initialize(view, vendor_user)
      @vendor = vendor_user.vendor
      @account = vendor_user.account
      super view
    end

    def total_subscribers
      ReportCalculation.total_subscribers(@npos)
    end

    def total_messages_sent
      ReportCalculation.total_messages_sent(@npos)
    end

    def total_messages_sent_this_month
      ReportCalculation.total_messages_sent(@npos, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_this_month
      ReportCalculation.total_collected_amount(@npos, Time.now.utc.beginning_of_month)
    end

    def total_collected_amount_for_previous_month
      ReportCalculation.total_collected_amount(@npos, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month)
    end

    def total_collected_amount_for_year_to_date
      ReportCalculation.total_collected_amount(@npos, Time.now.utc.beginning_of_year)
    end

    def total_offline_amount_for_year_to_date
      ReportCalculation.total_offline_amount(@npos, Time.now.utc.beginning_of_year)
    end

    def total_collected_amount
      ReportCalculation.total_collected_amount(@npos)
    end

    def total_accounts
      @npos.count
    end

    def active_accounts
      @npos.reject{|account| account.disabled?}.count
    end

    def account_enabled?
      @account.enabled?
    end

    def account_filter(params, ability)
      @account_filter ||= begin
        attrs = (params[:account_filter] || {}).merge(current_ability: ability)
        AccountFilter.new attrs
      end
    end
    def product_filter(params, ability)
      @product_filter ||= begin
        attrs = (params[:account_filter] || {}).merge(current_ability: ability)
        ProductFilter.new attrs
      end
    end

    def products_table(params)
      rows = []
      page = params[:page].present? ? params[:page] : 1
     @product_filter.products.order('products.asin').paginate(page: page, per_page: 30)
     # @product_filter.products.order('products.asin').each do |product|
     #    rows << {
     #        product: {id: product.id, asin: product.asin, description: product.description, item_number: product.item_number},
     #        # total_collected_previous_month: ReportCalculation.total_collected_amount(npo, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month),
     #        # total_collected_this_month: ReportCalculation.total_collected_amount(npo, Time.now.utc.beginning_of_month),
     #        # total_collected_ytd: ReportCalculation.total_collected_amount(npo, Time.now.utc.beginning_of_year),
     #        # total_offline_ytd: ReportCalculation.total_offline_amount(npo, Time.now.utc.beginning_of_year),
     #        # total_messages_this_month: 0 #ReportCalculation.total_messages_sent(npo, Time.now.utc.beginning_of_month)
     #    }
     #  end

    end

    def accounts_table
      rows = []
      @account_filter.accounts.order('npos.created_at desc').each do |npo|
        rows << {
            npo: {id: npo.id, name: npo.name, admin_id: npo.admin.try(:id)},
            total_collected_previous_month: ReportCalculation.total_collected_amount(npo, 1.month.ago.utc.beginning_of_month, 1.month.ago.utc.end_of_month),
            total_collected_this_month: ReportCalculation.total_collected_amount(npo, Time.now.utc.beginning_of_month),
            total_collected_ytd: ReportCalculation.total_collected_amount(npo, Time.now.utc.beginning_of_year),
            total_offline_ytd: ReportCalculation.total_offline_amount(npo, Time.now.utc.beginning_of_year),
            total_messages_this_month: 0 #ReportCalculation.total_messages_sent(npo, Time.now.utc.beginning_of_month)
        }
      end
      rows
    end

  end
end