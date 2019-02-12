class Admin::WorkbenchsController < Admin::BaseController
  layout 'operations_center'

  before_filter :check_operations_admin


  def npo_features
    @features = Feature.group(:name).where('npo_id != ?', -101).order(:name).count
    respond_to do |format|
      format.html { }
      format.json { render json: @features }
    end
  end

  def suspend_npo_feature
    if params[:name].blank?
      flash.alert = 'Feature name not provided!'
    elsif Feature.suspended?(params[:name])
      flash.alert = 'Feature already suspended!'
    else
      Feature.suspend(params[:name])
    end
    redirect_to npo_features_admin_workbenchs_path
  end

  def unsuspend_npo_feature
    if params[:name].blank?
      flash.alert = 'Feature name not provided!'
    else
      Feature.unsuspend(params[:name])
    end
    redirect_to npo_features_admin_workbenchs_path
  end



  def sessions
    @api_sessions = UserSession.order('expire_at desc').paginate page: params[:page], per_page: 30
    @web_sessions = UserActivityLog.select("DISTINCT user_id").where("created_at > ? and rpt_month = ?", 200.minutes.ago, Time.now.utc.to_s(:month_partition).to_i).order("created_at desc").paginate page: params[:page], per_page: 30

  end



  def job_details
    @job_details = {}
    job_id = params[:job][:job_id] if params[:job].present?
    @job = Jobs::Job.find_by_id (job_id)
    if @job.present?
      @job_details = @job.detail_rows.paginate(:page => params[:page], :per_page => (params[:per_page] || 30))
    end
  end

  def jobs
    scope = Jobs::Job
    scope = scope.where("name like ?", "%#{params[:job_type]}%") if params[:job_type].present?
    scope = scope.where('status is not null').order('created_at desc')
    @jobs = scope.paginate page: params[:page], per_page: 30
  end

  private

  def check_operations_admin
    # raise CanCan::AccessDenied unless current_user.operations_admin?
  end

end
