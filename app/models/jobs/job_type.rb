class Jobs::JobType < ActiveHash::Base
  self.data = [
      {id: 1, name: 'SalesData', :class_name => Jobs::SalesDataJob.name},
  ]
  # make_statusable

  class << self

    def available_job_types
      data.map { |d| d[:name] }
    end

    def find_by_class_name(name)
      data.detect { |d| d[:class_name] == name }
    end

    def find_by_name(name)
      data.detect { |d| d[:name] == name }
    end
  end
end
