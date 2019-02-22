class InventoriesController <  ApplicationController

  def index

  @out_of_stock = ProductInventory.where("instock_qty = 0").paginate page: params[:page], per_page: 30
  end

  def show
    p "in show"
    @product = Product.find_by_id(params[:id])
    @inventory = @product.product_inventory
  end


end
