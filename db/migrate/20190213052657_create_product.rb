class CreateProduct < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string   :asin
      t.string   :description
      t.integer  :item_number
    end
    add_index :products, :asin
  end
end
