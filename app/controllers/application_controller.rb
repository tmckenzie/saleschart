class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  include Mixins::Navigation

  helper_method :current_npo, :mcadmin_manage_links, :protocol,  :mc_admin?


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
      root_path
  end

  def clear_sso_session_info
    session.delete(:user)
  end


  def authenticate_user!(options = {})
    p 'Here'
    if session[:mc_admin_id].nil? && current_user && current_user.account && current_user.account.disabled?
      session[:account_disabled] = 'true'
      sign_out(current_user)
      clear_sso_session_info
    end
  ensure
    begin
      super
      p current_user
      p "user"
      if current_user

      else
        clear_sso_session_info
      end
    rescue => e
      p e
      raise Exception
      # Most likely current_user blew up. Clear session!
      Rails.logger.error "Session corrupted: #{e.message}"
      clear_sso_session_info if session.present?
      reset_session
      # redirect_to '/users/sign_in'
    end
  end



end
