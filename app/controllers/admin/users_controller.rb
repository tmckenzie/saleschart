class Admin::UsersController < Admin::BaseController

  load_and_authorize_resource except: [:become]

  before_filter :set_vendor, only: [:show, :new, :create, :edit, :update, :destroy]

  delegate :users, to: :user_filter

  def become
    user = User.find(params[:id])
    session[:mc_admin_id] = current_user.id
    sign_out(current_user)
    clear_sso_session_info
    sign_in(user, :bypass => true)
    redirect_to root_path
  end

  def index
    @users = users.order(:email).paginate(page: params[:page], per_page: (params[:per_page] || 30)) if current_user.mobilecause_admin?
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
  end

  def create
    @user = current_user.mobilecause_admin? ? User.new(params[:user]) : current_user.account.users.build(params[:user])
    @user.account = @vendor.account if @vendor.present? && @vendor.account.present?

    respond_to do |format|
      if @user.save
        @vendor.npo_events.create(npo_event_status: NpoEventStatus.user_created, user: current_user, description: "Created User: #{@user.email}",  originable: @user) if @vendor.present?
        if @user.app_user?
          UserNotification.find_or_create_from(@user.id, @user.id, UserNotification::NPO_NOTIFICATION_ON_RECURRING_DONATION_TERMINATION, "email")
        end
        ConstituentService.new.find_or_create_constituent(@user.phone_number)

        if @user.account.present? && @user.account.accountable.is_a?(Npo)
          Producer.publish({ :message_type => Fox::QueueTypes::ANALYTICS_QUEUE, :analytics_type => SisenseUserService::ADD_SSO_USER, :user_id => @user.id })
        end
        format.html { redirect_to (@vendor ? admin_vendor_user_path(@vendor, @user) : admin_user_path(@user)), notice: 'User was successfully created.' }
        format.json { render json: (@vendor ? admin_vendor_user_path(@vendor, @user) : admin_user_path(@user)), status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    #before update
    user_attrs = params[:user]
    unless @user.new_record?
      if user_attrs[:password].blank? && user_attrs[:password_confirmation].blank?
        user_attrs.delete(:password)
        user_attrs.delete(:password_confirmation)
      end
    end
    previous_number = @user.phone_number
    new_number = user_attrs[:phone_number]
    respond_to do |format|
      if @user.update_attributes(user_attrs)
        #after update
        path = determine_redirect_path
        format.html { redirect_to path, notice: 'User was successfully updated.' }
        format.js { render_remote_content 'modularized/form_errors' => {errors: [], flash_notice: 'Successfully updated user.'} }
      else
        format.html { render action: "edit" }
        format.js { render_remote_content 'modularized/form_errors' => {errors: @user.errors} }
      end
    end
  end

  def determine_redirect_path
    if @vendor.present?
      edit_admin_npo_path(@vendor)
    elsif @user.channel_partner?
      if current_user.mobilecause_admin
        admin_users_path(user_filter: {email: @user.email})
      else
        edit_account_settings_path
      end
    elsif current_user.mobilecause_admin
      admin_users_path(user_filter: {email: @user.email})
    else
      edit_account_settings_path
    end
  end

# DELETE /users/1
# DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to @vendor ? edit_admin_npo_path(@vendor) : admin_users_path }
      format.json { head :ok }
    end
  end

  # def user_report
  #   dr = DownloadRequest.create(status: RequestQueueStatus::QUEUED,
  #                               request_type: DownloadRequest::USER_REPORT,
  #                               user: current_user)
  #   redirect_to(root_url, notice: %Q[Your export has been queued. <a href="/download_requests">View progress</a>].html_safe)
  # end

  private

  def user_filter
    @user_filter ||= begin
      attrs = (params[:user_filter] || {})
      UserFilter.new attrs
    end
  end

  def set_vendor
    @vendor = Vendor.find(params[:npo_id]) if params[:npo_id]
  end
end
