class LoadData
  def self.run

    req = UploadRequest.create(upload_file_name: 'tmp/2019_UnitAndSales_US.csv')
    # UploadRequest.new
    UploadWorker.new.handle_queue_message({id: req.id}.with_indifferent_access)
    req = UploadRequest.create(upload_file_name: 'tmp/2018_UnitAndSales_US.csv')
    # UploadRequest.new
    UploadWorker.new.handle_queue_message({id:  req.id}.with_indifferent_access)
    req = UploadRequest.create(upload_file_name: 'tmp/2019_UnitAndSales_US.csv', request_type: INVENTORY_DATA)
    # UploadRequest.new
    UploadWorker.new.handle_queue_message({id: req.id}.with_indifferent_access)

  end
end