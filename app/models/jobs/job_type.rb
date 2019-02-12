class Jobs::JobType < ActiveHash::Base
  self.data = [
      {id: 1, name: 'ValidateAddress', :class_name => Jobs::ValidateAddressJob.name},
      {id: 2, name: 'SalesForceImport', :class_name => Jobs::SalesforceImportJob.name},
      {id: 3, name: 'UpdateSettlement', :class_name => Jobs::UpdateSettlementJob.name},
      {id: 4, name: 'MessagesReport', :class_name => Jobs::MessagesReportJob.name},
      {id: 5, name: 'KeywordReset', :class_name => Jobs::KeywordResetJob.name}
  ]
  make_statusable

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
