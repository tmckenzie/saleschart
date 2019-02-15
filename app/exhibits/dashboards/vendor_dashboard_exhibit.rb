module Dashboards
  class VendorDashboardExhibit < DashboardExhibit

    def panels_to_render
      # {
      #      :panel_1 => sales_panel,
      #      :panel_2 => inventory_panel,
      #      :panel_3 => people_panel,
      # #       :panel_4 => bottom_panel
      # }
      panels = set_panels(['sales_panel', 'inventory_panel', 'people_panel'])
      panels.merge!({:panel_4 => bottom_panel})

    end

    def set_panels(panel_list)
      panels = {}
      count =1
      panel_list.each do |panel|
        if can_render(panel)
          panels.merge!("panel_#{count}".to_sym => send(panel))
          count += 1
        end
      end
      p panels
    end

    def can_render(panel)
      p model.vendor
      ret = false
      if panel == 'people_panel'
        ret =  model.vendor.has_consumer_charts_feature? ? true : false
      elsif panel == 'inventory_panel'
        ret =  model.vendor.has_inventory_charts_feature? ? true : false
      elsif panel == 'sales_panel'
        ret =  model.vendor.has_sales_charts_feature? ? true : false
      end
      ret
    end

    def sales_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Sales"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_sales_rows(model.vendor)}},
              row_3: {partial: "dashboard/vendor/sales_links", locals: {vendor: model.vendor}},
          }
      }
    end

    def inventory_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Inventory"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_messaging_rows}}
          }
      }
    end

    def people_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "People"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_account_rows}}
          }
      }
    end

    def bottom_panel
      {
          partial: "dashboard/content_panel",
          rows: {
              row_1: {partial: "dashboard/vendor/products_panel", locals: {params: context.params, product_filter: model.product_filter(context.params.merge(:page => 'all'), context.current_ability), rows: model.products_table(context.params)}}
          }
      }
    end

    def total_collected_amount_for_this_month
      context.number_to_currency(model.total_collected_amount_for_this_month, precision: 0)
    end

    def total_collected_amount_for_previous_month
      context.number_to_currency(model.total_collected_amount_for_previous_month, precision: 0)
    end

    def total_collected_amount_for_year_to_date
      context.number_to_currency(model.total_collected_amount_for_year_to_date, precision: 0)
    end

    def total_offline_amount_for_year_to_date
      context.number_to_currency(model.total_offline_amount_for_year_to_date, precision: 0)
    end

    def total_collected_amount
      context.number_to_currency(model.total_collected_amount, precision: 0)
    end

    def total_accounts
      context.number_with_delimiter(model.total_accounts)
    end

    def active_accounts
      context.number_with_delimiter(model.active_accounts)
    end

    def known_deferred_methods
      [
          :total_collected_amount_for_year_to_date,
          :total_offline_amount_for_year_to_date,
          :total_collected_amount_for_this_month,
          :total_collected_amount_for_previous_month,
          :total_collected_amount,
          :total_accounts,
          :active_accounts
      ] + super
    end

    private

    def collect_account_rows
      [
          ['Total Accounts', deferred_call_for(:total_accounts)],
          ['Active Accounts', deferred_call_for(:active_accounts)],
          ['Total Subscribers', deferred_call_for(:total_subscribers)]
      ]
    end

    def collect_sales_rows(vendor)
      return [] if !vendor.has_sales_charts_feature?
      [
          ["Sales In #{current_month}", deferred_call_for('total_collected_amount_for_this_month')],
          ["Sales In #{previous_month}", deferred_call_for('total_collected_amount_for_previous_month')],
      ]
    end

    def collect_messaging_rows
      [
          ["Products Sold (#{current_month})", "N/A"],
          ['Product Sold (All Time)', "N/A"]
      #["Messages Sent (#{current_month})", deferred_call_for(:total_messages_sent_this_month)],
      #['Messages Sent (All Time)', deferred_call_for(:total_messages_sent)]
      ]
    end

  end
end