class CreateUploadRequest < ActiveRecord::Migration
  def change
    create_table :upload_requests do |t|
      t.integer  :npo_id
      t.integer  :user_id
      t.string   :request_type
      t.string   :status
      t.string   :upload_file_name
      t.string   :upload_content_type
      t.integer  :upload_file_size
      t.datetime :upload_updated_at
      t.datetime :upload_file_finished_at
      t.datetime :processing_started_at
      t.datetime :processing_finished_at
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :originable_id
      t.string   :originable_type
      t.integer  :account_id
    end
  end
end
