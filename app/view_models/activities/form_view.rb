module Activities
  class FormView < ViewModel
    delegate :id,
             :nonpayment_type?,
             :created_at,
             :collected_total,
             :collected_count,
         to: :model

    delegate :back_to_params, :npo, to: :activity

    def activity
      options[:activity]
    end

    def name
      model.form_name
    end

    def originable_type
      model.class.name
    end

    def edit_path
      edit_activity_path(activity.id, back_to_params.merge(panel: id, section: 'online-forms'))
    end

    def actions
      actions = []

      transaction_type_filter = if nonpayment_type?
        Filter::TransactionFilterView.non_payment_transaction_filter
      else
        Filter::TransactionFilterView.transaction_paid_filter
      end

      actions << {
        label: "View Transactions",
        path: transactions_path(back_to_params.merge(transaction_filter: transaction_type_filter.merge(form: id, campaigns_keyword_id: activity.id, campaign_id: activity.campaign.try(:id)))),
        icon_class: "fa-list"
      }

      if npo.has_allow_people_search_feature?
        actions << {
          label: "View Audience",
          path: peoples_path(back_to_params.merge(people_filter: { form: id })),
          icon_class: "fa-users"
        }
      end

      actions << {
        label: "Preview Form",
        path: RouteService.path_for(model, preview: "1"),
        icon_class: "fa-eye",
        target: "_blank"
      }
      actions << {
        label: "Edit Form",
        path: edit_path,
        icon_class: "fa-pencil-square-o"
      }
      actions
    end

    def date
      created_at.to_date.to_s
    end

    [:collected, :pending, :offline, :pledges].each do |stat|
      define_method "total_#{stat}" do
        amount_for_display(model.send("#{stat}_total"))
      end

      define_method "count_#{stat}" do
        count_for_display(model.send("#{stat}_count"))
      end
    end

    def average_gift
      if collected_total.present?
        avg_amount = collected_count > 0 ? (collected_total / collected_count) : 0
      end
      amount_for_display avg_amount
    end
  end
end