class RequestQueueStatus < ActiveHash::Base
  QUEUED = 'queued'
  PROCESSING = 'processing'
  COMPLETE = 'complete'
  ERROR_STATUS = 'error'
  EXPIRED = "expired"

  self.data = [
      {id: 1, name: QUEUED, friendly_name: "Queued"},
      {id: 2, name: PROCESSING, friendly_name: "Processing"},
      {id: 3, name: COMPLETE, friendly_name: "Completed"},
      {id: 4, name: ERROR_STATUS, friendly_name: "Error"}
  ]

  def self.incomplete
    self.all.reject{|d| d[:name] == COMPLETE || d[:name] == EXPIRED}
  end

  make_statusable
  def self.make_statusable
    self.data.each do |member|
      define_singleton_method(member[:name].downcase) do
        find_by_name(member[:name])
      end
    end

    self.data.each do |member|
      define_method("#{member[:name].downcase}?") do
        member[:id] == self.id
      end
    end
  end
end