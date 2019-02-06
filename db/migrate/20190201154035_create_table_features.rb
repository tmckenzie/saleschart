class CreateTableFeatures < ActiveRecord::Migration
  def up
    create_table :features do |t|
      t.references :vendor, null: false
      t.string :name
    end
    add_index(:features, [:vendor_id, :name], unique: true, name: 'index_vendor_features')
  end

  def down
    drop_table :features
  end
end
