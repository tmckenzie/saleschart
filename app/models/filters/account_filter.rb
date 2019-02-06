class AccountFilter
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :current_ability, :status, :legacy, :search_string, :name, :email, :account_type, :plan_name, :npo_id, :partner_id, :short_name

  def initialize(attrs = {})
    set_attrs(attrs)
  end

  def set_attrs(attrs, strict=true)
    (attrs || {}).each do |k, v|
      begin
        send "#{k}=", v
      rescue
        raise "#{k} is invalid filter param" if strict
      end
    end
  end


  def persisted?
  end

  def channel_partner_accounts
    @channel_partner_accounts ||= begin
      scope = ChannelPartner.includes(:account).accessible_by(current_ability)
    end

    if search_string.present?
      if search_string.split(":").count > 1
        json_hash = StringUtil.parse_search_string(search_string)
        set_attrs(json_hash, false)
      else
        @name = search_string
      end
    end

    if name.present?
      scope = scope.where 'name LIKE ?', "%#{name.strip}%"
    end

    scope
  end

  def reseller_accounts
    @reseller_accounts ||= begin
      scope = Reseller.includes(:account).accessible_by(current_ability)
    end

    if search_string.present?

      if search_string.split(":").count > 1
        json_hash = StringUtil.parse_search_string(search_string)
        set_attrs(json_hash, false)
      else
        @name = search_string
      end
    end

    if name.present?
      scope = scope.where 'name LIKE ?', "%#{name.strip}%"
    end

    scope
  end

  def freemium_accounts


    scope
  end

  def accounts
    @accounts ||= begin
      scope = Vendor.includes( account: [:users])

      if search_string.present?

        if search_string.split(":").count > 1
          json_hash = StringUtil.parse_search_string(search_string)
          set_attrs(json_hash, false)
        else
          @name = search_string
        end
      end

      if name.present?
        scope = scope.where 'name LIKE ?', "%#{name.strip}%"
      end

      scope = scope.where id: npo_id if npo_id.present?

      if status.present?
        case status
          when 'enabled'
            scope = scope.where('accounts.account_status = ?', Account::AccountStatus::ENABLED)
          when 'disabled'
            scope = scope.where('accounts.account_status = ?', Account::AccountStatus::DISABLED)
          when 'new'
            scope = scope.where("accounts.account_status = 1 AND billings.last_billed_date IS NULL AND legacy_account = false")
          else
            scope = scope.where('1 = 0')
        end
      end

      if email.present?
        email_kw = "%#{email.strip}%"
        scope = scope.where('(npos.email LIKE ? OR users.email LIKE ?)', email_kw, email_kw)
      end

      if plan_name.present?
        scope = scope.joins([:npo_contract]).where("npo_contracts.name LIKE ?", "#{plan_name.strip}%")
      end

    end

    scope
  end

end
