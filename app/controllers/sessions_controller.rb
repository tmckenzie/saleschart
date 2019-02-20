class SessionsController < Devise::SessionsController
  skip_before_filter :set_timezone
  skip_before_filter :authenticate_user!, only: [:new, :destroy]
  skip_before_action :verify_authenticity_token

  def destroy
    if current_user
      if session.include?(:mc_admin_id)
        logout_as
        return
      end
    end
    super
  end


  private


  def logout_as
    become_id = nil
    redirect_path = root_path

    if session.include?(:mc_admin_id)
      become_id = session.delete(:mc_admin_id)
      redirect_path = admin_vendors_path
    end

    admin = User.find(become_id)
    last_user_email = current_user.email
    sign_out(current_user)
    # clear_sso_session_info
    sign_in(:user, admin)
    redirect_to redirect_path, notice: "You are no longer signed in as #{last_user_email}"
  end
end
