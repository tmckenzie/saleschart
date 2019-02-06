module Filter
  class TransactionFilterView < FilterView
    SEARCH_TYPE = "transactions"

    # Filter sections
    TRANSACTION_TYPE_FILTERS = "transaction_type_filters"
    TRANSACTION_DATE_FILTERS = "transaction_date_filters"
    TRANSACTION_OTHER_FILTERS = "transaction_other_filters"
    TRANSACTION_ADMIN_FILTERS = "transaction_admin_filters"

    TRANSACTION_TYPE_CREDIT_CARD_OPTION = 'credit_card'
    TRANSACTION_TYPE_PAYPAL_OPTION = 'paypal'
    TRANSACTION_TYPE_OFFLINE_OPTION = 'offline'
    TRANSACTION_TYPE_NON_PAYMENT_OPTION = 'non_payment'
    TRANSACTION_TYPE_CHARGE_LATER_OPTION = 'charge_later'

    TRANSACTION_STATUS_COLLECTED_OPTION = 'collected'
    TRANSACTION_STATUS_PENDING_OPTION = 'pending'
    TRANSACTION_STATUS_VOIDED_OPTION = 'voided'
    TRANSACTION_STATUS_REFUNDED_OPTION = 'refunded'
    TRANSACTION_STATUS_UNCOLLECTIBLE_OPTION = 'uncollectible'
    TRANSACTION_STATUS_COMPLETED_OPTION = 'completed'
    TRANSACTION_STATUS_SUBMITTED_OPTION = 'submitted'

    TRANSACTION_TYPE_MAPPING =
        {
            TRANSACTION_TYPE_CREDIT_CARD_OPTION =>
                [
                    TransactionBillingType::SALE_BILLING_TYPE,
                    TransactionBillingType::CREDIT_BILLING_TYPE,
                    TransactionBillingType::RECURRING_BILLING_TYPE,
                    TransactionBillingType::TOKENIZE_SALE_BILLING_TYPE
                ],
            TRANSACTION_TYPE_PAYPAL_OPTION =>
                [
                    TransactionBillingType::PAYPAL_BILLING_TYPE,
                    TransactionBillingType::PAYPAL_CREDIT_BILLING_TYPE,
                    TransactionBillingType::PAYPAL_RECURRING_BILLING_TYPE
                ],
            TRANSACTION_TYPE_OFFLINE_OPTION => [TransactionBillingType::OFFLINE_BILLING_TYPE],
            TRANSACTION_TYPE_NON_PAYMENT_OPTION => [TransactionBillingType::NON_PAYMENT_BILLING_TYPE],
            TRANSACTION_TYPE_CHARGE_LATER_OPTION => [TransactionBillingType::TOKENIZE_BILLING_TYPE]
        }

    TRANSACTION_STATUS_MAPPING =
        {
            TRANSACTION_STATUS_COLLECTED_OPTION => TransactionStatus::SETTLED_BILLING_STATUS,
            TRANSACTION_STATUS_PENDING_OPTION => TransactionStatus::SUBMITTED_FOR_SETTLEMENT_BILLING_STATUS,
            TRANSACTION_STATUS_VOIDED_OPTION => TransactionStatus::VOIDED_BILLING_STATUS,
            TRANSACTION_STATUS_UNCOLLECTIBLE_OPTION => TransactionStatus::ERRORS_BILLING_STATUS,
            TRANSACTION_STATUS_COMPLETED_OPTION => TransactionStatus::COMPLETED_BILLING_STATUS,
            TRANSACTION_STATUS_SUBMITTED_OPTION => TransactionStatus::TOKENIZED_BILLING_STATUS
        }

    TRANSACTION_TYPE_OPTIONS =
        {
            TRANSACTION_TYPE_CREDIT_CARD_OPTION =>
                [
                    TRANSACTION_STATUS_COLLECTED_OPTION,
                    TRANSACTION_STATUS_PENDING_OPTION,
                    TRANSACTION_STATUS_REFUNDED_OPTION,
                    TRANSACTION_STATUS_VOIDED_OPTION,
                    TRANSACTION_STATUS_UNCOLLECTIBLE_OPTION
                ],
            TRANSACTION_TYPE_PAYPAL_OPTION =>
                [
                    TRANSACTION_STATUS_COLLECTED_OPTION,
                    TRANSACTION_STATUS_REFUNDED_OPTION,
                    TRANSACTION_STATUS_UNCOLLECTIBLE_OPTION
                ],
            TRANSACTION_TYPE_OFFLINE_OPTION => [TRANSACTION_STATUS_COLLECTED_OPTION],
            TRANSACTION_TYPE_NON_PAYMENT_OPTION => [TRANSACTION_STATUS_COMPLETED_OPTION],
            TRANSACTION_TYPE_CHARGE_LATER_OPTION => [TRANSACTION_STATUS_SUBMITTED_OPTION]
        }

    TRANSACTION_TOOLTIP =
        {
            TRANSACTION_TYPE_OFFLINE_OPTION => 'Any transaction entered manually, such as cash or check.',
            TRANSACTION_TYPE_NON_PAYMENT_OPTION => 'Any form submission with no payment associated, such as a survey, registration, or petition reponse.',
            TRANSACTION_TYPE_CHARGE_LATER_OPTION => 'Any transaction that was captured through Charge Later enabled forms and has not been processed.'
        }

    TRANSACTION_PAID_OPTIONS = {
        TRANSACTION_TYPE_CREDIT_CARD_OPTION => [TRANSACTION_STATUS_COLLECTED_OPTION, TRANSACTION_STATUS_PENDING_OPTION, TRANSACTION_STATUS_REFUNDED_OPTION],
        TRANSACTION_TYPE_PAYPAL_OPTION => [TRANSACTION_STATUS_COLLECTED_OPTION, TRANSACTION_STATUS_REFUNDED_OPTION]
    }

    NON_PAYMENT_OPTIONS = {
        TRANSACTION_TYPE_NON_PAYMENT_OPTION => [TRANSACTION_STATUS_COMPLETED_OPTION]
    }

    def self.transaction_paid_filter
      Filter::TransactionFilterView.new(nil, nil).to_filter_params(
          ActionController::Parameters.new(search: { txn_type: TRANSACTION_PAID_OPTIONS })
      )
    end

    def self.non_payment_transaction_filter
      Filter::TransactionFilterView.new(nil, nil).to_filter_params(
          ActionController::Parameters.new(search: { txn_type: NON_PAYMENT_OPTIONS })
      )
    end

    def filter_sections
      [
          TRANSACTION_TYPE_FILTERS,
          TRANSACTION_DATE_FILTERS,
          (ACTIVITY_FILTERS if !current_user.freemium_npo?),
          PERSON_INFO_FILTERS,
          TRANSACTION_OTHER_FILTERS,
          (TRANSACTION_ADMIN_FILTERS if current_user.mobilecause_admin?)
      ].compact
    end

    def txn_type_group_options
      txn_types = []
      opted_list = from_txn_type_filter_params(@filter.txn_type || {})
      TRANSACTION_TYPE_OPTIONS.clone.each do |option, list|
        sub_options = list.clone
        next if option == TRANSACTION_TYPE_OFFLINE_OPTION && current_user.freemium_npo?
        next if option == TRANSACTION_TYPE_CHARGE_LATER_OPTION && current_user.npo && !current_user.npo.has_donation_form_charge_later_feature?
        if current_user.freemium_npo?
          sub_options.delete(TRANSACTION_STATUS_VOIDED_OPTION)
          sub_options.delete(TRANSACTION_STATUS_REFUNDED_OPTION)
        end
        sub_options.delete(TRANSACTION_STATUS_UNCOLLECTIBLE_OPTION) unless current_user.mobilecause_admin?
        if opted_list.present?
          checked_option = opted_list.has_key?(option)
        else
          checked_option = default_txn_type?(option)
        end
        transaction_tooltip = TRANSACTION_TOOLTIP[option]
        hide_single_options = hide_list_if_single_option(sub_options)
        txn_types << {
            name: option,
            checked: checked_option,
            tooltip: transaction_tooltip,
            single: hide_single_options,
            options: sub_options.map do |o|
              if opted_list.present?
                checked_sub_option = checked_option && opted_list[option].include?(o)
              else
                checked_sub_option = default_txn_type?(option) && [TRANSACTION_STATUS_COLLECTED_OPTION, TRANSACTION_STATUS_PENDING_OPTION].include?(o)
              end
              {
                  name: o, checked: checked_sub_option
              }
            end
        }
      end
      txn_types
    end

    def txn_type_options
      txn_types = []
      TRANSACTION_TYPE_MAPPING.keys
      .reject { |o| o == 'charge_later' && current_user.npo && !current_user.npo.has_donation_form_charge_later_feature? }
      .reject { |o| o == 'offline' && current_user.freemium_npo? }
      .each do |key|
        option = { name: key, label: key.titleize, checked: key == 'credit_card' }
        if key == 'credit_card'
          option[:show_field] = 'txn_status'
        else
          option[:hide_field] = 'txn_status'
        end
        txn_types << option
      end
      txn_types
    end

    def txn_status_options
      available_options = [TransactionStatus::SETTLED_BILLING_STATUS, TransactionStatus::SUBMITTED_FOR_SETTLEMENT_BILLING_STATUS]
      available_options << TransactionStatus::VOIDED_BILLING_STATUS unless current_user.freemium_npo?
      available_options << TransactionStatus::ERRORS_BILLING_STATUS if current_user.mobilecause_admin?
      status_options = []
      available_options.each do |key|
        status_options << { name: key, label: TransactionStatus.find_by_name(key)[:friendly_name] }
      end
      status_options
    end

    def organization_names_by_organization_type
      return {} unless current_user.mobilecause_admin?
      {
          'NPO' => Npo.select(:name).map(&:name),
          'API Partner' => ChannelPartner.select(:name).map(&:name),
          'Reseller' => Reseller.select(:name).map(&:name)
      }
    end

    def payment_gateways
      return [] unless current_user.mobilecause_admin?
      PaymentProcessor.select(:processor_name)
      .map { |pp| [PaymentProcessorType.friendly_name(pp.processor_name), pp.processor_name] }
    end

    def field_value(name)
      case name.to_sym
        when :txn_type
          return self.class.txn_type_field_name(@filter.send(:billing_type))
        when :txn_status
          @filter.send(:billing_status)
        else
          @filter.send(name)
      end
    end

    def self.txn_type_field_name(types)
      if types.present?
        types = [types] if types.is_a?(String)
        TRANSACTION_TYPE_MAPPING.each do |key, options|
          return key if types.detect { |o| options.include?(o) }.present?
        end
      else
        ''
      end
    end

    def filter_date_range_value
      val = field_value(:date_range_str)
      val.presence || DateFilterType::CUSTOM
    end

    def filter_start_date
      val = field_value(:start_date)
      val.present? ? val : (DateTime.now.to_date - 7.days)
    end

    def filter_end_date
      val = field_value(:end_date)
      val.present? ? val : DateTime.now.to_date
    end

    def to_filter_params(params)
      attrs = params.require(:search)
      attrs, include_admin_attrs, include_other_options,
          include_date_options, include_activities, include_contact_info =
          params[:search], params[:admin_options], params[:other_options],
              params[:date_search], params[:activities], params[:contact_information]
      filter = {}

      if attrs[:txn_type].present?
        filter[:billing_type] = TRANSACTION_TYPE_MAPPING.slice(*attrs[:txn_type].keys).values.flatten.compact
      end
      filter[:billing_status] = attrs[:txn_status] if attrs[:txn_status].present?
      filter[:txn_type] = to_txn_type_filter_params(attrs[:txn_type]) if attrs[:txn_type].present?
      filter[:keyword_type] = attrs[:keyword_type] if attrs[:keyword_type].present?

      if include_date_options
        filter[:date_range_str] = attrs[:date_range_str] if attrs[:date_range_str].present?
        filter[:start_date] = attrs[:start_date] if attrs[:start_date].present?
        filter[:end_date] = attrs[:end_date] if attrs[:end_date].present?
      end

      if include_activities
        filter[:campaign_id] = attrs[:campaign_id] if attrs[:campaign_id].present?
        filter[:campaigns_keyword_id] = attrs[:campaigns_keyword_id] if attrs[:campaigns_keyword_id].present?
        filter[:campaign] = attrs[:campaign] if attrs[:campaign].present?
        filter[:keyword] = attrs[:keyword] if attrs[:keyword].present?
        filter[:form] = attrs[:form] if attrs[:form].present?
      end

      if include_contact_info
        filter[:phone] = attrs[:phone] if attrs[:phone].present?
        filter[:email] = attrs[:email] if attrs[:email].present?
        filter[:last_name] = attrs[:last_name] if attrs[:last_name].present?
        filter[:first_name] = attrs[:first_name] if attrs[:first_name].present?
      end

      if include_other_options
        filter[:amount_min] = attrs[:amount_min] if attrs[:amount_min].present?
        filter[:amount_max] = attrs[:amount_max] if attrs[:amount_max].present?
        filter[:last_4] = attrs[:last_4] if attrs[:last_4].present?
      end

      if include_admin_attrs
        filter[:organization_type] = attrs[:organization_type] if attrs[:organization_type].present?
        filter[:organization_name] = attrs[:organization_name] if attrs[:organization_name].present?
        filter[:payment_processor] = attrs[:payment_processor] if attrs[:payment_processor].present?
      end

      filter
    end

    def to_txn_type_filter_params(txn_type_attrs)
      filter_txn_type = {}
      txn_type_attrs.each do |txn_type, txn_statuses|
        refunded_option_requested = txn_statuses.delete(TRANSACTION_STATUS_REFUNDED_OPTION).present?
        if TRANSACTION_TYPE_MAPPING[txn_type].present?
          TRANSACTION_TYPE_MAPPING[txn_type].each do |billing_type|
            # exclude refunded billing type from search if not requested
            if refunded_billing_type?(billing_type)
              filter_txn_type[billing_type] = '' if refunded_option_requested
            elsif txn_statuses.present?
              filter_txn_type[billing_type] = txn_statuses.map { |status_option| TRANSACTION_STATUS_MAPPING[status_option] }
            end
          end
        end
      end
      filter_txn_type
    end

    def from_txn_type_filter_params(attrs)
      results = {}
      if attrs.present?
        search_attrs = {}
        attrs.each do |billing_type, billing_statuses|
          txn_type_option = TRANSACTION_TYPE_MAPPING.select { |o, billing_types| billing_types.include?(billing_type) }.keys.first
          if txn_type_option.present?
            search_attrs[txn_type_option] ||= []
            if refunded_billing_type?(billing_type)
              search_attrs[txn_type_option] += [TRANSACTION_STATUS_REFUNDED_OPTION]
            else
              search_attrs[txn_type_option] += TRANSACTION_STATUS_MAPPING.select { |o, billing_status| billing_statuses.include?(billing_status) }.keys
            end
            search_attrs[txn_type_option].uniq!
          end
        end
        # Rearrange to match the view options order
        TRANSACTION_TYPE_OPTIONS.each do |txn_type, statuses|
          if search_attrs[txn_type].present?
            results[txn_type] ||= []
            statuses.each { |val| results[txn_type] << val if search_attrs[txn_type].include?(val) }
          end
        end
      end
      results
    end

    def page_title
      "Search Transactions"
    end

    private

    def refunded_billing_type?(billing_type)
      [TransactionBillingType::PAYPAL_CREDIT_BILLING_TYPE, TransactionBillingType::CREDIT_BILLING_TYPE].include?(billing_type)
    end

    def default_txn_type?(type)
      [TRANSACTION_TYPE_CREDIT_CARD_OPTION, TRANSACTION_TYPE_PAYPAL_OPTION].include?(type)
    end

    def hide_list_if_single_option(sub_options)
      sub_options.size <= 1
    end
  end
end
