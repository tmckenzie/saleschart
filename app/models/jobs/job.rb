class Jobs::Job < ActiveRecord::Base
  has_many :job_stats, class_name: 'Jobs::JobStat'
  has_many :job_details, class_name: 'Jobs::JobDetail'
  has_one :account

  SCHEDULED_STATUS = "scheduled"
  PROCESSING_STATUS = "processing"
  COMPLETED_STATUS = "completed"
  ERROR_STATUS = "error"


  def self.scheduled
    Jobs::Job.where("status = ? and started_at is null", SCHEDULED_STATUS)
  end

  def self.processing
    Jobs::Job.where("status = ? and started_at is not null", PROCESSING_STATUS)
  end

  def self.errored
    Jobs::Job.where("status = ? and finished_at is not null", ERROR_STATUS)
  end

  def self.completed
    Jobs::Job.where("status = ? and finished_at is not null", COMPLETED_STATUS)
  end

  def add_stat(name, value)
    Jobs::JobStat.create(job_id: self.id, stat_name: name, stat_value: value)
  end

  def add_detail(detail_type, value, original_type = nil, originable_id = nil)
    Jobs::JobDetail.create(job_id: self.id, detail_type: detail_type, detail_value: value, originable_type: original_type, originable_id: originable_id)
  end

  def instance_job
    job_class.constantize
  end

  def start
    self.update_attributes({ status: PROCESSING_STATUS, started_at: Time.now, finished_at: nil })
  end

  def finish
    self.update_attributes({ finished_at: Time.now, status: COMPLETED_STATUS })
  end

  def finish_in_error
    self.update_attributes({ finished_at: Time.now, status: ERROR_STATUS })
  end

  def elapsed_time
    if started_at.present?
      return (finished_at || Time.now) - started_at
    end
    nil
  end

  def pretty_duration
    time = elapsed_time
    return if time.nil?
    parse_string =
        if time < 3600
          '%M:%S'
        else
          '%H:%M:%S'
        end

    Time.at(time).utc.strftime(parse_string)
  end

  def detail_rows
    job_details.where(detail_type: Jobs::JobDetail::ROW)
  end

  def detail_summary
    job_details.where(detail_type: Jobs::JobDetail::SUMMARY)
  end

  def job_instance
    Object.const_get job_type
  end

  def run
    raise "Not Implemented"
  end

end