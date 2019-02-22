class Product < ActiveRecord::Base

  has_one :product_sale
  has_one :product_inventory

end