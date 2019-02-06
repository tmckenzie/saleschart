# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  # CanCan's :manage is too permissive.  Prefer CRUD unless you know otherwise
  CRUD = [:create, :read, :update, :destroy]

  def initialize(user)
    return unless user

    if user.vendor && user.account && user.account.accountable_type == 'Vendor'
      can [:manage], Vendor, id: user.vendor.id
      can :become, User


      if user.vendor_admin?
        can CRUD, User, :account_id => user.account_id
      end

    end

    if user.account && user.account.accountable_type == 'Master'
        can CRUD, User, :account_id => user.account_id
        can :manage, Vendor
        can :manage, Account
        can :manage, User
        can :become, User
    end


  end
end

