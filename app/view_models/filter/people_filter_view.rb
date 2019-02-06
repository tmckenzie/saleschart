module Filter
  class PeopleFilterView < FilterView
    SEARCH_TYPE = "people"

    # Filter sections
    PERSON_DONATION_FILTERS = "person_donation_filters"
    PERSON_LOCATION_FILTERS = "person_location_filters"

    CONSTITUENT_INVALID_STATUS    = "invalid"
    CONSTITUENT_UNVERIFIED_STATUS = "unverified"
    CONSTITUENT_VERIFIED_STATUS   = "verified"

    CONSTITUENT_INVALID_STATUS_OPTION    = "invalid"
    CONSTITUENT_UNVERIFIED_STATUS_OPTION = "unverified"
    CONSTITUENT_VERIFIED_STATUS_OPTION   = "verfied"

    CONSTITUENT_STATUS_OPTION = "status"

    PHONE_STATUS_OPTIONS =
      {
          CONSTITUENT_STATUS_OPTION =>
              [
                  CONSTITUENT_INVALID_STATUS,
                  CONSTITUENT_UNVERIFIED_STATUS,
                  CONSTITUENT_VERIFIED_STATUS
              ]
      }

    PHONE_TOOLTIP =
      {
         CONSTITUENT_INVALID_STATUS_OPTION    => "Phone status invalid",
         CONSTITUENT_UNVERIFIED_STATUS_OPTION => "Phone status unverified",
         CONSTITUENT_VERIFIED_STATUS_OPTION   => "Phone status verified"
      }

    def verified_mobile_number_options
      phone_tooltip = PHONE_TOOLTIP[Constituent::VERIFIED_STATUS]
      txn_types = [ {
                        name: Constituent::VERIFIED_STATUS,
                        checked: default_txn_type?(Constituent::VERIFIED_STATUS),
                        tooltip: phone_tooltip,
                        single:  true,
                        options: [name: Constituent::VERIFIED_STATUS, checked: false]
                    }]
      txn_types
    end

    def field_value(name)
      @filter.send(name)
    end

    def to_filter_params(params)
      attrs = params.require(:search)
      filter = {}
      filter[:keyword_type] = attrs[:keyword_type] if attrs[:keyword_type].present?
      filter[:campaign_id] = attrs[:campaign_id] if attrs[:campaign_id].present?
      filter[:campaigns_keyword_id]  = attrs[:campaigns_keyword_id] if attrs[:campaigns_keyword_id].present?
      filter[:form]     = attrs[:form] if attrs[:form].present?
      filter[:phone] = attrs[:phone] if attrs[:phone].present?
      filter[:status] = to_carrier_status_filter_params(attrs[:status]) if attrs[:status].present?
      filter[:email] = attrs[:email] if attrs[:email].present?

      filter[:last_name] = attrs[:last_name] if attrs[:last_name].present?
      filter[:first_name] = attrs[:first_name] if attrs[:first_name].present?
      filter[:amount_min] = attrs[:amount_min] if attrs[:amount_min].present?
      filter[:amount_max] = attrs[:amount_max] if attrs[:amount_max].present?
      filter[:last_4] = attrs[:last_4] if attrs[:last_4].present?
      filter[:state]   = attrs[:state] if attrs[:state].present?
      filter[:city]   = attrs[:city] if attrs[:city].present?
      filter[:zip]   = attrs[:zip] if attrs[:zip].present?
      if attrs[:verified_address].present?
        filter[:verified_address] = true
      end

      filter
    end

    def to_carrier_status_filter_params(carrier_status_params)
      carrier_status = []
      carrier_status_params.each do |status, phone_statuses|
        carrier_status = phone_statuses
      end
      carrier_status
    end

    def page_title
      "Create Segment"
    end

    def icon_class
      Navigation::Menu::MENU_ICON_MAPPING['Contacts']
    end

    def filter_sections
      [
        PERSON_INFO_FILTERS,
        ACTIVITY_FILTERS,
        PERSON_DONATION_FILTERS,
        PERSON_LOCATION_FILTERS
      ]
    end

    private

    def default_txn_type?(type)
      [CONSTITUENT_STATUS_OPTION].include?(type)
    end

    def hide_list_if_single_option(sub_options)
      sub_options.size <= 1
    end
  end
end