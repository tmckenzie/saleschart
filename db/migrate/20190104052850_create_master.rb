class CreateMaster < ActiveRecord::Migration
  def change
    create_table :masters do |t|
      t.string :name

      t.timestamps
    end
  end
end
