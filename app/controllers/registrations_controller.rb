class RegistrationsController < Devise::RegistrationsController
  def edit
  end

  def update
    if params[:enable_recurring_failed_notification].present?
      # UserNotification.find_or_create_from(@user.id, @user.id, UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, "email")
    else
      # UserNotification.destroy_all(user_id: @user.id, notify_id: @user.id, notify_type: UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, delivery_method: "email")
    end
    super
  end
end