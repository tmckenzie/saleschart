class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :account
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def account_type
    self.mobilecause_admin? ? "MobileCause" : self.account.try(:accountable_type)
  end

  def vendor
    @vendor ||= (account.present? && account.is_npo?) ? account.accountable : nil
  end

  def name
    # [first_name, last_name].map(&:presence).join ' '
  end

  def name=(name)
    # self[:first_name], self[:last_name] = name.split ' '
  end

  def beta_feature_admin?
    beta_user_emails = %w(
    admin@mobilecause.com
    )
    beta_user_emails.include? self[:email]
  end

  def mcmaster_admin?
    mcmaster_admin_emails = %w(

    admin@mobilecause.com)
    mcmaster_admin_emails.include? self[:email]
  end

  def operations_admin?
    operations_emails = %w(
     admin@mobilecause.com
     )
    operations_emails.include? self[:email]
  end

  def mobilecause_admin?
    true
  end

  def mmp_admin?
    account.present? && account.is_master?
  end

  def super_admin?
    "admin@mobilecause.com" == self[:email]
  end

  def verified?
     true
  end

  def current_role=(role)
    @current_role = role
  end

  def current_role_pf?
    false
  end

  def current_role_dual?
   false
  end

  def app_user?
    @app_user ||= begin
      ret = false
      if mmp_admin? || vendor_admin?
        ret = true
      end
      ret
    end
  end

  def dual_user?
    fundraiser? && app_user?
  end

  def peer_fundraisers
    # Join with campaigns keyword to weed out any deleted keywords.

  end

  def generate_api_token
    self.reset_authentication_token!
    save(:validate => false)
  end

  def generate_public_auth_token
    # Generate an authentication_token for any user that needs a public auth token because if their
    # authentication_token is nil then it's highly possible to get multiple users with the same
    # public auth token which is bad.
    generate_api_token if self.authentication_token.nil?
    self.public_auth_token = UserSession.generate_public_token(self.authentication_token)
    save(:validate => false)
  end

  def multi_user?
    @multi_user ||= email.present? ? User.where(email: email).count > 1 : false
  end

  def account_name
    @account_name ||= begin
      account_name = ""
      account_name = "MC Admin" if mobilecause_admin
      account_name = npo.try(:name) if account_name.blank?
      account_name = account.try(:accountable).try(:name) if account_name.blank?
      account_name = peer_fundraisers.first.fundraising_name if account_name.blank? && peer_fundraisers.present?
      account_name
    end
  end

  def can_access_npo?(npo_id)
    return true if mobilecause_admin?
    npo_ids = []
    case account.try(:accountable_type)
      when Account::AccountType::CHANNEL_PARTNER
        npo_ids = account.npos.map(&:id)
      when Account::AccountType::NPO
        npo_ids = [account.accountable.id]
    end
    npo_ids.include?(npo_id)
  end

  #######
  private


  def create_username
    if self.username.blank?
      100.times do |num|
        self.username = generate_user_name(self.first_name, self.last_name, self.email, num)
        break if valid?
      end
      if self.invalid?
        10.times do
          self.username =  "user#{rand(1000)}"
          break if valid?
        end
      end
    end
  end
end
