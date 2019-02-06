class Account < ActiveRecord::Base
  belongs_to :accountable, :polymorphic => true
  has_many :users
  has_many :npo_groups

  accepts_nested_attributes_for :users

  delegate :name, to: :accountable

  module AccountStatus
    DISABLED = 0
    ENABLED  = 1
    PENDING  = 2
  end

  module AccountType
    VENDOR = "Vendor"
    MASTER = "Master"
  end

  def enabled?
    account_status == AccountStatus::ENABLED
  end

  def pending?
    account_status == AccountStatus::PENDING
  end

  def disabled?
    account_status == AccountStatus::DISABLED
  end

  def is_vendor?
    accountable_type == AccountType::VENDOR
  end

  def is_master?
    accountable_type == AccountType::MASTER
  end

  def is_npo?
    true
  end
end