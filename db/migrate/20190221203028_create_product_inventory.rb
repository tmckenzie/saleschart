class CreateProductInventory < ActiveRecord::Migration
  def change
    create_table :product_inventories do |t|
      t.references :product, null: false
      t.date :scrape_dt
      t.string :sku
      t.string :fnsku
      t.integer :instock_qty
      t.integer :inbound_qty
      t.integer :transfer_qty
      t.integer :unsellable_qty
      t.integer :working_qty
      t.integer :instock_supply_qty
      t.integer :reserved_orders
      t.integer :reserved_fcprocessing
      t.string :from_remapped_sku
    end
    # drop_table :inventories
  end
end
