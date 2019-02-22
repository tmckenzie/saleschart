class AddInventory < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.references :product, null: false
      t.date :scrape_dt
      t.integer :sku
      t.integer :fnsku
      t.integer :instock_qty
      t.integer :inbound_qty
      t.integer :transfer_qty
      t.integer :unsellable_qty
      t.integer :working_qty
      t.integer :instock_supply_qty
      t.integer :reserved_orders
      t.integer :reserved_fcprocessing
      t.integer :from_remapped_sku
    end
  end
end
