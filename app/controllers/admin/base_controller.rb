class Admin::BaseController < ApplicationController
  before_filter :verify_admin, :verify_account_enabled
  private
  # use simple before filters until admin roles become more complex
  # then switch to this https://github.com/ryanb/cancan/wiki/Admin-Namespace
  def verify_admin
    raise CanCan::AccessDenied unless current_user.account.accountable.is_a?(Master)
  end

  def verify_account_enabled
    raise CanCan::AccessDenied unless current_user.account.accountable.is_a?(Master) || current_user.account.enabled?
  end
end