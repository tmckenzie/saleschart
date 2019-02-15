class CreateJobDetails < ActiveRecord::Migration
  def change
      create_table :job_details do |t|
        t.references :job, null: false
        t.integer :seq_num
        t.string :detail_type
        t.text :detail_value
        t.integer :originable_id
        t.string :originable_type
        t.timestamps
      end
      add_index :job_details, :job_id
  end
end
