class UsersController < ApplicationController
  load_and_authorize_resource except: [:select_role, :set_role, :tokenized_sign_in]

  before_filter :verify_account_enabled, only: [:become]
  before_filter :verify_npo, only: [:new, :create]
  skip_before_filter :authenticate_user!, only: [:select_role, :set_role, :tokenized_sign_in]
  before_filter :verify_dual_user, only: [:select_role, :set_role]
  layout :determine_layout

  def become
    user = User.find(params[:id])
    p user
    if current_user.mobilecause_admin?
      session[:mc_admin_id] = current_user.id
    end
    sign_out(current_user)
    # clear_sso_session_info
    sign_in(user, :bypass => true)
    redirect_to(params[:r].presence || root_path)
  end

  def select_role
  end

  def set_role
    if params[:role] == "fundraiser"
      ok_to_proceed = verify_and_set_current_role_to_pf(User::DUAL_USER_ROLE)
    else
      set_current_user_role User::APP_USER_ROLE
      ok_to_proceed = true
    end
    redirect_to(root_path) if ok_to_proceed
  end

  # NOT USED
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { @user = current_user }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    @user.account = current_user.account
    respond_to do |format|
      if @user.save
        if @user.app_user?
          UserNotification.find_or_create_from(@user.id, @user.id, UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, "email")
        end

        if @user.npo.present?
          @user.npo.npo_events.create(npo_event_status: NpoEventStatus.user_created, user: current_user, description: "Created User: #{@user.email}", originable: @user)
        end
        Producer.publish({ :message_type => Fox::QueueTypes::ANALYTICS_QUEUE, :analytics_type => SisenseUserService::ADD_SSO_USER, :user_id => @user.id })

        format.html {
          if current_user.channel_partner?
            redirect_to edit_account_settings_path, notice: 'User was successfully created.'
          else
            redirect_to vendor_user_path(@user), notice: 'User was successfully created.'
          end
        }
        format.json { render json: vendor_user_path(@user), status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        if params[:enable_recurring_failed_notification].present?
          UserNotification.find_or_create_from(@user.id, @user.id, UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, "email")
        else
          UserNotification.destroy_all(user_id: @user.id, notify_id: @user.id, notify_type: UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, delivery_method: "email")
        end
        if @user.account.present? && @user.account.accountable.is_a?(Npo)
          @user.npo.npo_events.create(npo_event_status: NpoEventStatus.user_updated, user: current_user, description: "Updating User: #{@user.email}", originable: @user)
        end
        Producer.publish({ :message_type => Fox::QueueTypes::ANALYTICS_QUEUE, :analytics_type => SisenseUserService::UPDATE_SSO_USER, :user_id => @user.id })
        path = (current_user.reseller? || current_user.channel_partner?) ? edit_account_settings_path : account_path
        format.html { redirect_to path, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @user.account.present? && @user.account.accountable.is_a?(Npo)
      @user.npo.npo_events.create(npo_event_status: NpoEventStatus.user_deleted, user: current_user, description: "Deleting User: #{@user.email}")
    end
    sso_user_setting = @user.user_settings.where(setting_type: 'sisense_sso').first
    if sso_user_setting.present?
      Rails.logger.info("sso_user_setting for user id: #{@user.id} - #{sso_user_setting.inspect}")
      Producer.publish({ :message_type => Fox::QueueTypes::ANALYTICS_QUEUE, :analytics_type => SisenseUserService::DELETE_SSO_USER, :sisense_user_id => sso_user_setting.setting_value })
    end

    @user.destroy
    redirect_path = current_user.account.is_channel_partner? ? edit_account_settings_path : account_path

    respond_to do |format|
      format.html { redirect_to redirect_path }
      format.json { head :ok }
    end
  end

  def tokenized_sign_in
    sign_out(current_user) if current_user
    one_time_token = UserSession.find_by_session_token(params[:token]) if params[:token].present?
    if one_time_token.present?
      sign_in(:user, one_time_token.user) if one_time_token.user
      one_time_token.destroy
    end
    if params[:r].present?
      redirect_to params[:r]
    else
      redirect_to root_path
    end
  end

  private

  def verify_account_enabled
    raise CanCan::AccessDenied unless current_user.mobilecause_admin? || current_user.account.enabled?
  end

  def verify_dual_user
    if current_user.nil? || !current_user.dual_user?
      raise CanCan::AccessDenied
    end
  end

  def verify_npo
    unless current_npo || current_user.account.is_channel_partner?
      redirect_to(root_url, :alert => "You are not authorized to access this page")
    end
  end

  def determine_layout
    case action_name
      when "select_role"
        "registration"
      else
        'application'
    end
  end
end
