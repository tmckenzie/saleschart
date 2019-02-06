class CreateVendor < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name

      t.timestamps
    end
  end
end
