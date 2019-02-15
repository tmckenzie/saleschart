class UploadRequest < ActiveRecord::Base

  SPHERE_DATA = 'Sphere Data'
  CONSTITUENT_DATA = 'upload'
  PAGE_CSS_DATA = 'page_css'
  OFFLINE_DONATION_DATA = 'offline_donation'

  REQUEST_TYPES =
      [
          SPHERE_DATA,
          CONSTITUENT_DATA
      ]

  MIN_TIME_TO_AUTO_DESTROY = 15 # seconds

  belongs_to :account
  belongs_to :user
  belongs_to :originable, polymorphic: true


  def display_name
    "#{self.user.email} #{self.npo.present? ? "(npo: #{self.npo.name})" : ''}"
  end

  def status_pending?
    self.status == RequestQueueStatus::QUEUED || self.status == RequestQueueStatus::PROCESSING
  end

  def processing_time
    return nil if self.processing_started_at.nil?
    return -1 if self.processing_finished_at.nil?
    self.processing_finished_at - self.processing_started_at
  end

  class << self
    def downloadable
      where('upload_requests.status != ?', RequestQueueStatus::EXPIRED)
    end

    def order_by_processing_started_at_desc
      order('processing_started_at DESC, created_at DESC')
    end
  end

  private
  def set_account_id
    # self.account_id = npo.account_id
  end
end
