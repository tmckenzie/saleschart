class Admin::VendorsController < Admin::BaseController
  before_filter :save_user_params, only: [:create]
  before_filter :save_account_params, only: [:create, :update]
  load_and_authorize_resource :vendor, :except => [:create]
  helper_method :accounts, :account_filter

  def index
    if current_user.mobilecause_admin? && current_user.vendor.present?
      # flash.notice = 'Both a mobilecause admin and belongs to an npo, unable to create a new Npo. Contact support'
    end
    @vendors_list = accounts.paginate page: params[:page], per_page: 30

    respond_to do |format|
      format.html # index1.html.erb
      format.json { render json: @vendors }
      format.csv { render csv: @vendors_list, filename: "accounts-#{params[:type]}-#{Time.now.to_s :file}" }
    end
  end

  delegate :accounts, to: :account_filter

  def account_filter
    @account_filter ||= begin
      attrs = (params[:account_filter] || {}).merge(current_ability: current_ability)
      AccountFilter.new attrs
    end
  end

  def edit
    @error_messages ||= []
  end

  # GET /npos/1
  # GET /npos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.js { render_remote_content("admin/npos/show_usage_stats" => {npo: @vendor}) }
      format.json { render json: @vendor }
    end
  end

  # GET /npos/new
  # GET /npos/new.json
  def new
    @vendor.users.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vendor }
    end
  end

  # POST /npos
  # POST /npos.json
  def create
    @vendor = Vendor.new(vendor_params)
    p vendor_params
    respond_to do |format|
      if @vendor.save
        @user_params.merge!(vendor_admin: true)
        @vendor.account.users.create(@user_params)
        @vendor.users.each do |user| user.save! end

        @vendor.account.update_attributes(account_status: @account_params) if @account_params.present?
        # @vendor.create_features_from_partner_account_feature_template
        user = @vendor.account.users.first
        format.html { redirect_to edit_admin_vendor_path(@vendor), notice: 'Account was successfully created. Please verify Organization info, Remittance info and Billing info for this account.' }
        format.json { render json: @vendor, status: :created, location: @vendor }
      else
        format.html { render action: "new" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        @vendor.account.update_attributes(account_status: @account_params) if @account_params.present?
        # @vendor.create_features_from_partner_account_feature_template
        format.json { render json: nil, status: :ok }
        format.html { redirect_to edit_admin_vendor_path(@vendor, anchor: 'settings_tab'), notice: 'Npo was successfully updated.' }
      else
        format.json { render json: @vendor.errors.full_messages.to_sentence, status: :unprocessable_entity }
        format.html { render :edit }
      end
    end
  end

  def edit_features
    respond_to do |format|
      format.js { render_remote_content('accounts/edit_feature_settings') }
      format.html {}
    end
  end

  def update_features
    respond_to do |format|
      if @vendor.update_features_from(params[:vendor])
        format.js { render_remote_content({"accounts/vendor_feature_settings" => {vendor: @vendor.reload, view_only: false}, 'admin/npos/summary_row' => {npo: @vendor}}) }
        format.html { redirect_to edit_admin_vendor_path(@vendor, anchor: 'features_tab'), notice: 'Features updated.' }
      else
        @errors = @vendor.errors.full_messages
        format.json { render json: @errors.to_sentence, status: :unprocessable_entity }
        format.js { render json: @errors.to_sentence, status: :unprocessable_entity }
        format.html { render 'admin/npos/edit' }
      end
    end
  end



  ########
  private

  def save_user_params
    @user_params = params[:vendor].has_key?(:users) ? params[:vendor].delete(:users) : {}
  end

  def save_account_params
    @account_params = params[:vendor].has_key?(:account_status) ? params[:vendor].delete(:account_status) : {}
  end

  def user_params

    params.require(:vendor).permit( :name, :email, :account, :account_status, :id, users: [:name, :email, :passsword, :password_confirmation])

  end
  def vendor_params
    params.require(:vendor).permit( :name, :email, :account, :account_status, :id, users: [:name, :email, :passsword, :password_confirmation])

  end
end