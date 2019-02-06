module Search
  class TransactionSearchExhibit < SearchExhibit
    def initialize(*)
      super
      define Filter::TransactionFilterView::TRANSACTION_DATE_FILTERS, partial: "transaction_date_filters"
    end

    # TODO: the * here should no longer be necessary in an upcoming release of Blocks 3.1.
    #  It is currently necessary because Blocks is expecting the method to take at least
    #  one argument (likely the Blocks::RuntimeContext) and is not handling the case
    #  properly when the method takes no arguments.
    def person_info_filters(*)
      fields = []
      fields += [
          text_field(:first_name),
          text_field(:last_name),
          text_field(:email),
          text_field(:phone)
      ]
      render_search_section(:contact_information, fields)
    end

    def transaction_type_filters(*)
      fields = []
      fields << checkbox_field(:txn_type, view_model.txn_type_group_options, 'Transaction Type', false, true)
      render_search_section(:report_columns, fields, header: false)
    end

    def transaction_other_filters(*)
      fields = []
      fields += [
          prepended_text_field(:amount_min, 'Minimum Amount'),
          prepended_text_field(:amount_max, 'Maximum Amount'),
          text_field(:last_4, 'Last 4 On Credit Card', 4)
      ]
      render_search_section(:other_options, fields, label: "Payment Information")
    end

    def saved_objects
      account_id = view_model.current_user.mobilecause_admin? ? nil : view_model.current_user.account.id
      AccountObject.where(account_id: account_id, parent_id: nil)
    end

    def transaction_admin_filters(*)
      fields = [
        select_field(:organization_type, 'Organization Type', 'All organization types',
                     view_model.organization_names_by_organization_type.keys.sort, view_model.field_value(:organization_type)),
        text_field(:organization_name, 'Organization Name', nil,
                   { autocomplete: true, options: view_model.organization_names_by_organization_type }),
        select_field(:payment_processor, 'Payment Gateway', 'All payment gateways', view_model.payment_gateways,
                     view_model.field_value(:payment_processor))
      ]
      render_search_section(:admin_options, fields)
    end
  end
end
