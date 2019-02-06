module Filter
  class FundraiserFilterView < FilterView

    delegate :start_date, :end_date, :campaign, :keyword, :npo, :campaigns_keyword_id, :status, :fundraisers,
             to: :filters

    def status_filters_from(current_filters)
      filters = []
      if current_filters.present?
        current_filters.each do |status_name, value|
          filters << status_name if value == 'true'
        end
      else
        filters = PeerFundraiserStatus.reviewable_statuses.map(&:to_s)
      end
      filters
    end

  end
end