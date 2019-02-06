class Feature < ActiveRecord::Base
  V2 = 'v2'
  BETA_CODE = "beta_code"
  EVENT_MANAGEMENT= "event_management"
  SALES_CHARTS = 'sales_charts'
  INVENTORY_CHARTS = 'inventory_charts'
  CONSUMER_CHARTS = 'consumer_charts'

  module DisabledDisplayOption
    HIDDEN = 'hidden'
    DISABLED = 'disabled'
    NEW_TAB = 'new_tab'
    MODAL = 'modal'
  end

  module Status
    AVAILABLE = 'Available'
    UNAVAILABLE = 'Not Available'
    SUSPENDED = 'Suspended'
    REMOVED = 'Removed'
  end

  belongs_to :vendor
  validates_presence_of :name
  validates :name, :uniqueness => { :scope => :vendor_id }

  #********** PLEASE READ before you add a new feature ***********#
  #>> display_name key makes the npo feature visible on UI and makes it available to user for toggling the feature.
  #>> has_<your_feature_name_here>_feature? is the dynamic npo helper method you would use for checking whether npo has the feature or not.
  #>> Provide npo_has_feature_method_name key only if you don't like the has_<your_feature_name_here>_feature? method name.
  #>> Provide after_build_callback key if you need to run some code right after building the feature for an npo. Please note feature is not persisted to db at this point.
  #>> Make sure to add after_build_callback instance method to the Npo class.
  #>> Provide after_delete_callback key if you need to run some code right after deleting the feature for an npo.
  #>> Make sure to add after_delete_callback instance method to the Npo class.
  #********** PLEASE READ before you add a new feature ***********#

  LIST =
      [
          { name: V2 },
          { name: SALES_CHARTS, display_name: 'Sales Charts' },
          { name: INVENTORY_CHARTS, display_name: 'Inventory Charts' },
          { name: CONSUMER_CHARTS, display_name: 'Consumer Charts' },
               ].sort_by { |k, v|  k[:display_name] || "" }.push({ name: BETA_CODE, display_name: 'Beta Features', plan: nil })

  BETA_LIST =
      [

      ].sort_by { |k, v|  k[:display_name] }

  class << self
    def displayable_list
      LIST.select { |feature| feature[:display_name].present? }
    end

    def from_name(name)
      (LIST + BETA_LIST).select { |feature| feature[:name] == name }.first
    end

    def display_name(feature_name)
      available_feature = self.from_name(feature_name)
      available_feature ? available_feature[:display_name] : ''
    end

    def features_for_plan(plan_type)
      LIST.select { |d| d[:plan] == plan_type }
    end

    def feature_names
      (LIST.select { |d| d[:name]} + BETA_LIST.select  { |d| d[:name]}).map{|d| d[:name]}
    end

    def features_for_base_plan()
      list = [DONOR_NOTIFICATION_EMAIL, DONOR_NOTIFICATION_SMS, RICH_TEXT_EDITING, MAIN_DASHBOARD_ANALYTICS]
      LIST.select { |status| list.include?(status[:name]) }.map{|d| d}
    end

    def suspended?(feature_name)
      self.where(vendor_id: -101, name: feature_name).count > 0
    end

    def suspend(feature_name)
      self.create(vendor_id: -101, name: feature_name)
    end

    def unsuspend(feature_name)
      self.where(vendor_id: -101, name: feature_name).delete_all
    end

    def status(feature_name)
      status = Status::AVAILABLE
      available_feature = self.from_name(feature_name)
      if available_feature
        status = Status::UNAVAILABLE unless available_feature.has_key?(:display_name)
        status = Status::SUSPENDED if Feature.suspended?(feature_name)
      else
        status = Status::REMOVED
      end
      status
    end
  end
end
