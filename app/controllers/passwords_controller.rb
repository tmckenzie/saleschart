class PasswordsController < Devise::PasswordsController
  # POST /resource/password
  def create
    if params[:login].present?
      user = User.find_by_username(params[:login])
      user.send_reset_password_instructions

      if successfully_sent?(user)
        respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(user)
      end

      return
    elsif params[:user].present? && params[:user][:email].present?
      email = params[:user][:email]
      if User.where(email: email).count > 1
        redirect_to select_user_path(params.merge({ result: 'password_reset' }))
        return
      end
    end

    super
  end
end
