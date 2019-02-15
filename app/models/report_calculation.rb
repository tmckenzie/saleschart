class ReportCalculation

  class << self
    def total_collected_amount(npos = nil, start_date = nil, end_date = Time.now.utc)
      p"collected"
      scope = ProductSale.where('product_sales.sales_date <= ?', end_date)
      scope = scope.where('product_sales.amount is not null')
      scope = scope.where('product_sales.sales_date >= ?', start_date) if start_date.present?
      # scope = scope.where(npo_id: npos) if npos
      scope.select(:amount).map(&:amount).sum
    end

    def total_offline_amount(npos = nil, start_date = nil, end_date = Time.now.utc)
      p "offline"
      scope = Transaction.settled.where('transactions.created_at <= ?', end_date)
      scope = scope.where('transactions.billing_type = ?', TransactionBillingType::OFFLINE_BILLING_TYPE )
      scope = scope.where('transactions.created_at >= ?', start_date) if start_date.present?
      scope = scope.where(npo_id: npos) if npos
      scope.select(:amount).map(&:amount).sum
    end

    def total_pending_amount(npos = nil, start_date = nil, end_date = Time.now.utc)
    p 'pending'
      scope = Transaction.submitted_for_settlement.where('transactions.created_at <= ?', end_date)
      scope = scope.where('transactions.created_at >= ?', start_date) if start_date.present?
      scope = scope.where(npo_id: npos) if npos
      scope.select(:amount).map(&:amount).sum
    end

    def last_collection_date(npo)
      p "last"
      Transaction.settled.where(npo_id: npo.id).maximum(:created_at)
    end

    def total_messages_sent(npos = nil, start_date = nil, end_date = Time.now.utc)
      scope = Campaign.joins(:messages => [:mobile_terminateds, :batch])
      scope = scope.where(:mobile_terminateds => {state: MobileTerminated::STATE_SENT})
      scope = scope.where('batches.created_at between ? and ? ', start_date, end_date ) if start_date.present?
      scope = scope.where(npo_id: npos) if npos
      scope.count
    end

    def total_subscribers(npos = nil)
      scope = NposConstituent.subscribed.verified
      scope = scope.where(npo_id: npos) if npos
      scope.uniq.count
    end

    def total_email_subscribers(npos = nil)
      scope = NposConstituentContact.filter_by(contactable_type: EmailConstituent.name, npo_id: npos)
      scope = scope.joins(:constituent_lists_npos_constituent_contacts).where('constituent_lists_npos_constituent_contacts.subscription_status = ?', NposConstituent::SUBSCRIBED)
      scope.uniq.count
    end

    def total_donors(npos = nil)
      #TODO add Npo.id to donations
      scope = Donation.pledged.joins(campaigns_keyword: [campaign: [:npo]]).joins(:npos_constituent)
      scope = scope.where(:campaigns => {npo_id: npos}) if npos
      scope.map(&:npos_constituent_id).uniq.count
    end

    def total_pledged_amount(npos = nil, start_date = nil, end_date = Time.now.utc)
      if npos
        campaign_ids = Campaign.where('npo_id in (?)', npos).select(:id)
        return 0 if campaign_ids.blank?
      end
      scope = Donation.pledged.joins(:campaigns_keyword)
      scope = scope.where('donations.amount is not null')
      scope = scope.where('donations.created_at >= ?', start_date) if start_date.present?
      scope = scope.where('donations.created_at <= ?', end_date)
      scope = scope.where('campaigns_keywords.campaign_id in (?)', campaign_ids) if campaign_ids.present?
      scope.select(:amount).map(&:amount).sum
    end

    def recurring_donation_remaining_this_year(recurring_donation)
      return if recurring_donation.nil?

      amount = 0
      donation = Donation.select('amount').where('recurring_donation_id = ?', recurring_donation.id).where('amount is not null').first
      period = RecurringDonationFrequency.find_by_name(recurring_donation.frequency)[:period]
      dt = recurring_donation.next_bill_date
      current_year = Time.now.year
      while dt.year == current_year
        amount += donation.amount
        dt += period
      end
      return amount
    end

    def recurring_donation_collected(recurring_donation, start_date = nil, end_date = Time.now.utc)

      return if recurring_donation.nil?

      scope = Transaction.settled.where('transactions.created_at <= ?', end_date)
      scope = scope.where('transactions.created_at >= ?', start_date) if start_date.present?
      scope = scope.joins(:donation)
      scope = scope.where('donations.recurring_donation_id = ?', recurring_donation.id)
      scope.select('transactions.amount').map(&:amount).sum
    end
  end

end
