class CreateJobsStats < ActiveRecord::Migration
  def change
    create_table :job_stats do |t|
      t.references :job, null: false
      t.integer :stat_value
      t.string  :stat_name
      t.timestamps
    end
    add_index :job_stats, :job_id
  end
end
