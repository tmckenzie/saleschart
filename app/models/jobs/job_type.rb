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
