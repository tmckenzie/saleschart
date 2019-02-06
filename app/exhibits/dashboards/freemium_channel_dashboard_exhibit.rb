module Dashboards
  class FreemiumChannelDashboardExhibit < DashboardExhibit

    def panels_to_render
      {
          :panel_1 => fundraising_panel,
          :panel_2 => widget_stats_panel,
          :panel_4 => bottom_panel
      }
    end

    def fundraising_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Fundraising"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_fundraising_rows}},
              row_3: {partial: "dashboard/summary_panel_note", locals: {note: "** Remittance checks are sent with fees removed on the 15th of the month for the previous month's donations."}}
          }
      }
    end

    def widget_stats_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Widget Stats"}},
          }
      }
    end

    def bottom_panel
      {
          partial: "dashboard/content_panel",
          rows: {
              row_1: {partial: "dashboard/freemium_channel/freemium_accounts_table", locals: {freemium_filter: model.freemium_filter(context.params, context.current_ability), free_accounts: model.freemium_accounts_table}}
          }
      }
    end

    def total_collected_amount_for_this_month
      context.number_to_currency(model.total_collected_amount_for_this_month, precision: 0)
    end

    def total_collected_amount_for_previous_month
      context.number_to_currency(model.total_collected_amount_for_previous_month, precision: 0)
    end

    def total_collected_amount
      context.number_to_currency(model.total_collected_amount, precision: 0)
    end

    def total_accounts
      context.number_with_delimiter(model.total_accounts)
    end

    def known_deferred_methods
      [
          :total_collected_amount_for_this_month,
          :total_collected_amount_for_previous_month,
          :total_collected_amount,
          :total_accounts
      ] + super
    end

    private

    def collect_fundraising_rows
      [
          ["Collected In #{current_month}", deferred_call_for('total_collected_amount_for_this_month')],
          ["Collected In #{previous_month}", deferred_call_for('total_collected_amount_for_previous_month')],
          ["Collected (All Time)", deferred_call_for('total_collected_amount')],
          ['Total Accounts', deferred_call_for('total_accounts')]
      ]
    end

  end
end