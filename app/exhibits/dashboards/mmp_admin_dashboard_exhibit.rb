module Dashboards
  class MMPAdminDashboardExhibit < DashboardExhibit

    def panels_to_render
      {
          panel_1: fundraising_panel,
          panel_2: messaging_panel,
          panel_3: manage_panel,
          panel_4: ops_center
      }
    end

    def fundraising_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Fundraising"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_fundraising_rows}}
          }
      }
    end

    def messaging_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Messaging"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_messaging_rows}}
          }
      }
    end

    def manage_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Manage"}},
              row_2: {partial: "dashboard/mc_admin/manage_links", locals: {links_collection: context.mcadmin_manage_links}}
          }
      }
    end

    def ops_center
      model.operations_admin? ?
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Ops Center"}},
              row_2: {partial: "dashboard/mc_admin/ops_center_links"}
          }
      } : {}
    end

    def total_collected_amount_for_this_month
      context.number_to_currency(model.total_collected_amount_for_this_month, precision: 0)
    end

    def total_collected_amount_for_previous_month
      context.number_to_currency(model.total_collected_amount_for_previous_month, precision: 0)
    end

    def total_collected_amount
      view.number_to_currency(view_model.total_collected_amount, precision: 0)
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
          #["Collected In #{current_month}", deferred_call_for('total_collected_amount_for_this_month')],
          #["Collected In #{previous_month}", deferred_call_for('total_collected_amount_for_previous_month')],
          #["Collected (All Time)", deferred_call_for('total_collected_amount')],
          ["Collected In #{current_month}", "N/A"],
          ["Collected In #{previous_month}", "N/A"],
          ["Collected (All Time)", "N/A"],
          ['Total Accounts', deferred_call_for('total_accounts')]
      ]
    end

    def collect_messaging_rows
      [
          ["Messages Sent (#{current_month})", "N/A"],
          ['Messages Sent (All Time)', "N/A"],
          ['Total Subscribers', "N/A"]
          #["Messages Sent (#{current_month})", deferred_call_for(:total_messages_sent_this_month)],
          #['Messages Sent (All Time)', "N/A"],
          #['Total Subscribers', deferred_call_for(:total_subscribers)]
      ]
    end

  end
end