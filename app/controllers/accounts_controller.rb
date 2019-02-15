class AccountsController < ApplicationController
  load_and_authorize_resource :user

  layout :determine_layout


  def show
  end

  def show_features
    respond_to do |format|
      format.js { render_remote_content('accounts/vendor_feature_settings' => { vendor: @vendor, view_only: true }) }
      format.json { render json: @npo }
      format.html {}
    end
  end

  def edit_home_page
    view_model = ::Pages::ConfigView.new(view_context, @account.find_or_create_account_page)
    @exhibitor = ::Pages::ConfigExhibit.new(view_model, view_context)
  end

  def tr_data
    @tr_data ||= remittance_info.generate_braintree_tr_data updated_account_billing_info_url
  end

  def error_messages
    @error_messages ||= []
  end

  def update_qr_brand_settings
    redirect_to account_url(@npo, anchor: 'panel_organization_logo')
  end

  def update_settings
    logo_file_name = params[:npo][:logo_file_name]

    if @npo.present? && logo_file_name.present? && logo_file_name.starts_with?("http")
      @npo.logo_from_url logo_file_name
    elsif @npo.present? && params[:npo][:logo].present?
      @npo.logo = params[:npo][:logo]
    end

    if @npo.present? && @npo.save
      flash.notice = "Organization logo was updated."
      respond_to do |format|
        format.html { redirect_to account_url(@npo, anchor: 'panel_organization_logo') }
        format.json { render json: { image: @npo.logo(:large), img_type: 'npo_logo' }, status: :created }
      end
    else
      @error_msg = @npo.errors.full_messages.reject { |msg| msg =~ /identify/ }.last if @npo.present?
      respond_to do |format|
        format.html { redirect_to account_url(@npo, anchor: 'panel_organization_logo'), alert: 'Organization logo was not updated.' }
        format.json { render json: @error_msg, status: :unprocessable_entity }
      end
    end
  end

  def update_qr_brand
    file = params[:npo][:qr_brand]
    component = 'qr_brand'
    component_id = params[:npo_id]

    max_qr_size = Concerns::ImageSizeValidationConcern::DEFAULT_QR_SIZE_VALIDATION
    if file.size > max_qr_size
      @error_msg = "QR image cannot be greater than #{ActiveSupport::NumberHelper.number_to_human_size(max_qr_size)}"
      respond_to do |format|
        format.json { render json: @error_msg, status: :unprocessable_entity }
      end
      return
    end
    unless @error_msg.present?
      new_image = ImageService.new.create_image_for(component, component_id, file, @npo.account)
      # @peer_fundraiser.update_attributes(file_attr => file)
      image_url = new_image.shared_image.shared_img.url
    end
    respond_to do |format|
      format.json { render json: { image: image_url }, status: :created }
    end
  end

  def update_analytics
    google_analytics_key = params[:npo][:google_analytics_key]
    @npo.google_analytics_key = google_analytics_key if google_analytics_key.present?
    if @npo.save
      redirect_to account_url(@npo, anchor: 'panel_analytics'),  notice: 'Google Analytics Tracking ID was successfully updated.'
    else
      render :edit, anchor: 'panel_analytics'
    end
  end

  def upload_image
    # file_attr = params[:for_preview] == 'true' ? :tmp_personal_img : :personal_img
    file = params[:banner_img].present? ? params[:banner_img] : params[:team_img]
    component = params[:component]
    component_id = params[:team_id]

    # new_image = ImageService.new.create_image_for(component, component_id, file, @peer_fundraiser_team.campaigns_keyword.campaign.npo.account)
    # @peer_fundraiser.update_attributes(file_attr => file)
    image_url = new_image.shared_image.shared_img.url
    respond_to do |format|
      format.json { render json: { image: image_url }, status: :created }
    end
  end

  def set_npo
    if current_user.npo.present?
      @npo = current_npo
      @account = current_npo.account
    elsif current_user.channel_partner.present?
      @channel_partner = current_user.channel_partner
      @account = current_user.channel_partner.account
    end
  end

  def set_organization
    @organization = current_user.account.accountable
  end
end