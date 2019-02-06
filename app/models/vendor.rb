class Vendor < ActiveRecord::Base
  has_one :account, :as => :accountable, :autosave => true
  delegate :users, to: :account
  after_initialize :initialize_account
  has_many :features

  (Feature::LIST + Feature::BETA_LIST).each do |available_feature|
    next if available_feature[:display_only]
    # add npo has_feature? helper methods
    npo_has_feature_method_name = available_feature[:npo_has_feature_method_name].present? ? available_feature[:npo_has_feature_method_name] : "has_#{available_feature[:name]}_feature?"
    define_method(npo_has_feature_method_name) do
      has_feature?(available_feature[:name])
    end
    # add attr_writers
    define_method("feature_#{available_feature[:name]}=") do |value|
      raise ArgumentError.new("'#{value}' not a boolean") unless !!value == value
      if value
        build_feature(available_feature[:name])
        send(available_feature[:after_build_callback]) if available_feature[:after_build_callback].present?
      else
        remove_feature(available_feature[:name])
        send(available_feature[:after_delete_callback]) if available_feature[:after_delete_callback].present?
      end
    end
  end

  def update_features_from(attrs)
    attrs.each do |feature_name, feature_val|
      send("#{feature_name}=", feature_val == 'true')
    end
    self.save
  end


  def self.human_attribute_name(attribute, options={})
    {
        :name => 'Organization Name',
        :email => 'Organization Info Email'
    }[attribute] || super
  end


  def build_feature(f)
    self.features.build(name: f) unless has_feature?(f, false)
  end

  def create_feature(f)
    self.features.create(name: f) unless has_feature?(f, false)
  end

  def remove_feature(f)
    feature = self.features.find_by_name(f)
    feature.destroy if feature.present?
  end

  def initialize_account
    if new_record?
      build_account
    end
  end

  def account_status=(val)
    account.account_status = val
  end

  def account_status
    account.account_status
  end

  def admin
    admins = account.users.where('vendor_admin = ?', true)
    admins.first
  end

  def has_feature?(name, check_suspended = true)
    flag = self.features.map(&:name).include?(name)
    flag = flag && !Feature.suspended?(name) if check_suspended
    flag
  end

  def current_account_status
    if enabled?
      return 'Enabled'
    elsif pending?
      return 'Pending'
    else
      return 'Disabled'
    end
  end

  def enabled?
    account.enabled?
  end

  def pending?
    account.pending?
  end

  def disabled?
    account.disabled?
  end


  def is_demo?
    false
  end


end