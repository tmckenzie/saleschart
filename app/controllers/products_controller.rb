class ProductsController <  ApplicationController

  helper_method :products, :product_filter

  def index

    @products = products.paginate page: params[:page], per_page: 30

    respond_to do |format|
      format.html # index1.html.erb
      format.json { render json: @products }
      format.csv { render csv: @products, filename: "products-#{params[:type]}-#{Time.now.to_s :file}" }
    end
  end

  def show
    p "in show"
    @product = Product.find_by_id(params[:id])
    last_year_start_date ||= Date.today.prev_year.beginning_of_year
    last_year_end_date ||= Date.today.prev_year.end_of_year
    start_date ||=  Date.today.beginning_of_year
    end_date ||=  Date.today.end_of_year
    @current_year_pie = Charts::PieView.new.simple_pie( QueryManagers::Mysql::SqlQueryManager.new().product_sales_by_year_month(@product.id,start_date, end_date))
    @last_year_pie = Charts::PieView.new.simple_pie( QueryManagers::Mysql::SqlQueryManager.new().product_sales_by_year_month(@product.id,last_year_start_date,last_year_end_date))

  end

  delegate :products, to: :product_filter

  def product_filter
    @product_filter ||= begin
      attrs = (params[:product_filter] || {}).merge(current_ability: current_ability)
      ProductFilter.new attrs
    end
  end
end
