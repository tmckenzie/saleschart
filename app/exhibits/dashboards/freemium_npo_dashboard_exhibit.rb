module Dashboards
  class FreemiumNpoDashboardExhibit < DashboardExhibit
    include ActionView::Helpers::UrlHelper

    def panels_to_render
      {
          :panel_1 => fundraising_panel,
          :panel_2 => support_center_panel,
          :panel_3 => marketing_panel,
          :panel_4 => bottom_panel
      }
    end

    def fundraising_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Donations"}},
              row_2: {partial: "dashboard/summary_list", locals: {rows: collect_fundraising_rows}},
              row_3: {partial: "dashboard/freemium_npo/get_report_button", locals: {ck: model.npo.active_keywords.first}}
          }
      }
    end

    def support_center_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Support"}},
              row_2: {partial: "dashboard/freemium_npo/support_links"}
          }
      }
    end

    def marketing_panel
      {
          partial: "dashboard/summary_panel",
          rows: {
              row_1: {partial: "dashboard/summary_panel_header", locals: {name: "Get Started"}},
              row_2: {partial: "dashboard/freemium_npo/marketing_content"}
          }
      }
    end

    def bottom_panel
      {
          partial: "dashboard/content_panel",
          rows: {
              row_1: {partial: "dashboard/shared/edit_online_gift", locals: {campaigns_keyword: model.online_giving_ck, label: "Donation Page Setup"}}
          }
      }
    end

    def total_collected_amount
      context.number_to_currency(model.total_collected_amount, precision: 0)
    end

    def total_pledged_amount
      context.number_to_currency(model.total_pledged_amount, precision: 0)
    end

    def total_donors
      context.number_with_delimiter(model.total_donors)
    end

    def known_deferred_methods
      [
          :total_collected_amount,
          :total_pledged_amount,
          :total_donors
      ] + super
    end

    # TODO: ahunter - remove this method once all dashboards are using the admin layout
    def layout
      "givenow"
    end

    private

    def collect_fundraising_rows
      [
          ['Total Collected', deferred_call_for('total_collected_amount')],
          ['Total Pending', "$0"],
          ['Total Donors', deferred_call_for('total_donors')]
      ]
    end
  end
end