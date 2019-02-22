class LoadInventory
  def self.run

    req = UploadRequest.create(upload_file_name: 'tmp/inventory.csv', request_type: UploadRequest::INVENTORY_DATA)
    # UploadRequest.new
    UploadWorker.new.handle_queue_message({id: req.id}.with_indifferent_access)

  end
end