class Jobs::JobDetail < ActiveRecord::Base
  SUMMARY = 'summary'
  ROW = 'row'

  belongs_to :job
end