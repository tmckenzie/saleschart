class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :name
      t.string :job_type
      t.string :job_class
      t.boolean :server
      t.string :status
      t.integer :account_id
      t.integer :total_count
      t.integer :succeeded_count
      t.integer :failed_count
      t.string :results
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
  end
end
