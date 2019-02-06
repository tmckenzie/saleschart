module Filter
  # Search filters
  ACTIVITY_FILTERS = "activity_filters"
  PERSON_INFO_FILTERS = "person_info_filters"

  RADIO_CB_CONTROL_TYPE = :radio_checkbox
  CHECKBOX_CONTROL_TYPE = :checkbox
  TEXT_CONTROL_TYPE = :textbox
  DATETIME_CONTROL_TYPE = :datetime
  DATE_CONTROL_TYPE = :date

  class FilterView

    # Search types
    TRANSACTION_SEARCH = "transactions"
    PEOPLE_SEARCH = "people"
    SEARCH_TYPES = [TRANSACTION_SEARCH, PEOPLE_SEARCH]

    attr_reader :current_user, :filter

    def initialize(filter, current_user)
      @filter = filter
      @current_user = current_user
    end

    def self.build_search_filter(filter, current_user)
      if filter.is_a?(TransactionFilter)
        view = Filter::TransactionFilterView.new(filter, current_user)
      elsif filter.is_a?(FundraiserFilter)
        view = Filter::FundraiserFilterView.new(filter, current_user)
      elsif filter.is_a?(PeopleFilter)
        view = Filter::PeopleFilterView.new(filter, current_user)
      else
        view = Filter::FilterView.new(filter, current_user)
      end
      view
    end

    def page_title
    end

    def icon_class
      Navigation::Menu::MENU_ICON_MAPPING['Search Transactions']
    end

    def filter_sections
      []
    end

  end
end