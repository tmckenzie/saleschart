class CreateProductSales < ActiveRecord::Migration
  def change
    create_table :product_sales do |t|
      t.references :product, null: false
      t.date :sales_date
      t.integer :amount
      t.string  :quantity
      t.timestamps
    end
    add_index :product_sales, [:product_id, :sales_date], unique: true, name: 'uq_sale'
  end
end
