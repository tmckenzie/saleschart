require 'json'

class UploadWorker

  def initialize(logger = nil)

  end

  def handle_queue_message(message)

    @request = UploadRequest.find(message['id'])

    process_request(@request)

  rescue => e
    p "Error in UploadWorker.handle_queue_message: #{e.message}\nStack trace:\n#{e.backtrace.join("\n")}"
  ensure
    # @request.complete if @request.present?
  end


  def process_request(request)
    case request.request_type
      when UploadRequest::INVENTORY_DATA
        run_inventory(request)
      when UploadRequest::SALES_DATA
        run_sales(request)
    end
  end

  def run_sales(request)
    job = Jobs::SalesDataJob.new(name: 'LoadSalesData', :job_class => Jobs::SalesDataJob.name)
    job.start

    total_products_created = process_list(request)

    job.finish
    job.update_attributes({total_count: total_products_created})
  end

  def run_inventory(request)
    job = Jobs::InventoryDataJob.new(name: 'LoadSalesData', :job_class => Jobs::InventoryDataJob.name)
    job.start

    total_products_created = process_inventory(request)

    job.finish
    job.update_attributes({total_count: total_products_created})
  end

#private

  def get_file_name(request)
    tmp_file = request.get_file
    tmp_file.path
  end

  def delete_file(file_name)
    File.delete(file_name)
  rescue
    # ignore deleting
  end

# List Processing stuff
  def process_list(request)
    total_products_created = 0
    csv_file_path = request.upload_file_name
    data = ::CSV.foreach(csv_file_path, {:headers => true, :encoding => 'ISO-8859-1'}) do |row|
      total_products_created +=process_row(row)
    end
    total_products_created
  end

# ASIN	Type	Description	Item #	1/1/19	1/2/19	1/3/19	1/4/19	1/5/19	1/6/19	1/7/19	1/8/19	1/9/19	1/10/19	1/11/19	1/12/19	1/13/19	1/14/19	1/15/19	1/16/19	1/17/19	1/18/19	1/19/19	1/20/19	1/21/19	1/22/19	1/23/19	1/24/19	1/25/19	1/26/19	1/27/19	1/28/19	1/29/19	1/30/19	1/31/19	2/1/19	2/2/19	2/3/19	2/4/19	2/5/19	2/6/19	2/7/19	2/8/19	2/9/19	2/10/19	2/11/19	2/12/19	2/13/19	2/14/19	2/15/19	2/16/19	2/17/19	2/18/19	2/19/19	2/20/19	2/21/19	2/22/19	2/23/19	2/24/19	2/25/19	2/26/19	2/27/19	2/28/19	3/1/19	3/2/19	3/3/19	3/4/19	3/5/19	3/6/19	3/7/19	3/8/19	3/9/19	3/10/19	3/11/19	3/12/19	3/13/19	3/14/19	3/15/19	3/16/19	3/17/19	3/18/19	3/19/19	3/20/19	3/21/19	3/22/19	3/23/19	3/24/19	3/25/19	3/26/19	3/27/19	3/28/19	3/29/19	3/30/19	3/31/19	4/1/19	4/2/19	4/3/19	4/4/19	4/5/19	4/6/19	4/7/19	4/8/19	4/9/19	4/10/19	4/11/19	4/12/19	4/13/19	4/14/19	4/15/19	4/16/19	4/17/19	4/18/19	4/19/19	4/20/19	4/21/19	4/22/19	4/23/19	4/24/19	4/25/19	4/26/19	4/27/19	4/28/19	4/29/19	4/30/19	5/1/19	5/2/19	5/3/19	5/4/19	5/5/19	5/6/19	5/7/19	5/8/19	5/9/19	5/10/19	5/11/19	5/12/19	5/13/19	5/14/19	5/15/19	5/16/19	5/17/19	5/18/19	5/19/19	5/20/19	5/21/19	5/22/19	5/23/19	5/24/19	5/25/19	5/26/19	5/27/19	5/28/19	5/29/19	5/30/19	5/31/19	6/1/19	6/2/19	6/3/19	6/4/19	6/5/19	6/6/19	6/7/19	6/8/19	6/9/19	6/10/19	6/11/19	6/12/19	6/13/19	6/14/19	6/15/19	6/16/19	6/17/19	6/18/19	6/19/19	6/20/19	6/21/19	6/22/19	6/23/19	6/24/19	6/25/19	6/26/19	6/27/19	6/28/19	6/29/19	6/30/19	7/1/19	7/2/19	7/3/19	7/4/19	7/5/19	7/6/19	7/7/19	7/8/19	7/9/19	7/10/19	7/11/19	7/12/19	7/13/19	7/14/19	7/15/19	7/16/19	7/17/19	7/18/19	7/19/19	7/20/19	7/21/19	7/22/19	7/23/19	7/24/19	7/25/19	7/26/19	7/27/19	7/28/19	7/29/19	7/30/19	7/31/19	8/1/19	8/2/19	8/3/19	8/4/19	8/5/19	8/6/19	8/7/19	8/8/19	8/9/19	8/10/19	8/11/19	8/12/19	8/13/19	8/14/19	8/15/19	8/16/19	8/17/19	8/18/19	8/19/19	8/20/19	8/21/19	8/22/19	8/23/19	8/24/19	8/25/19	8/26/19	8/27/19	8/28/19	8/29/19	8/30/19	8/31/19	9/1/19	9/2/19	9/3/19	9/4/19	9/5/19	9/6/19	9/7/19	9/8/19	9/9/19	9/10/19	9/11/19	9/12/19	9/13/19	9/14/19	9/15/19	9/16/19	9/17/19	9/18/19	9/19/19	9/20/19	9/21/19	9/22/19	9/23/19	9/24/19	9/25/19	9/26/19	9/27/19	9/28/19	9/29/19	9/30/19	10/1/19	10/2/19	10/3/19	10/4/19	10/5/19	10/6/19	10/7/19	10/8/19	10/9/19	10/10/19	10/11/19	10/12/19	10/13/19	10/14/19	10/15/19	10/16/19	10/17/19	10/18/19	10/19/19	10/20/19	10/21/19	10/22/19	10/23/19	10/24/19	10/25/19	10/26/19	10/27/19	10/28/19	10/29/19	10/30/19	10/31/19	11/1/19	11/2/19	11/3/19	11/4/19	11/5/19	11/6/19	11/7/19	11/8/19	11/9/19	11/10/19	11/11/19	11/12/19	11/13/19	11/14/19	11/15/19	11/16/19	11/17/19	11/18/19	11/19/19	11/20/19	11/21/19	11/22/19	11/23/19	11/24/19	11/25/19	11/26/19	11/27/19	11/28/19	11/29/19	11/30/19	12/1/19	12/2/19	12/3/19	12/4/19	12/5/19	12/6/19	12/7/19	12/8/19	12/9/19	12/10/19	12/11/19	12/12/19	12/13/19	12/14/19	12/15/19	12/16/19	12/17/19	12/18/19	12/19/19	12/20/19	12/21/19	12/22/19	12/23/19	12/24/19	12/25/19	12/26/19	12/27/19	12/28/19	12/29/19	12/30/19	12/31/19
  def process_row(row)
    product_created =0
    p ret_product = process_product(row['ASIN'], row['Type'], row['Description'], row[3])
    product = ret_product.present? ? ret_product[0] : nil
    if product.present?
      product_created = ret_product[1] ? 1 : 0
      (row.length - 4).times do |i|
        p row.headers[i+4]
        date = nil
        begin
          date= Date.strptime(row.headers[i+4], "%m/%d/%y")
        rescue
          p "bad date"
          row
        end

        if date.present?
          if row['Type'] == "Units"
            process_sales_units(product, date.to_s, row[i+4])
          elsif row['Type'] == "Sales"
            process_sales_dollars(product, date.to_s, row[i+4])
          end
        end
      end
    end
    product_created
  end

  def process_product(asin, type, desc, item, create= true)
    return if asin == "----"
    created=false
    product= Product.find_by_asin(asin)
    if product.nil? && create
      product = Product.create(asin: asin, description: desc, item_number: item)
      created=true
    end
    p [product, created]
  end

  def process_sales_dollars(product, date, value)
    return if value == "0" || value.nil?
    productsale= ProductSale.find_by_product_id_and_sales_date(product.id, date)
    if productsale.nil?
      ProductSale.create(product_id: product.id, sales_date: date, amount: value)
    else
      productsale.update_attributes(amount: value)
    end

  end

  def process_sales_units(product, date, value)
    return if value == "0" || value.nil?
    productsale= ProductSale.find_by_product_id_and_sales_date(product.id, date)
    if productsale.nil?
      ProductSale.create(product_id: product.id, sales_date: date, quantity: value)
    else
      productsale.update_attributes(quantity: value)
    end

  end

  def process_inventory(request)
    total_products_created = 0
    csv_file_path = request.upload_file_name
    data = ::CSV.foreach(csv_file_path, {:headers => true, :encoding => 'ISO-8859-1'}) do |row|
      total_products_created +=process_inv_row(row)
    end
    total_products_created
  end

  def process_inv_row(row)
    count = 0
    p ret_product = process_product(row['asin'], row['Type'], row['Description'], row[3], false)
    product = ret_product.present? ? ret_product[0] : nil
    if product.present?
      p row
      count +=1
      ProductInventory.create(product_id: product.id,
                             scrape_dt: row['scrape_date'],
                             sku: row['sku'],
                             fnsku: row['FNSKU'],
                             instock_qty: row['Instock'],
                             inbound_qty: row['Inbound'],
                             transfer_qty: row['Transfer'],
                             unsellable_qty: row['Unsellable'],
                             working_qty: row['WorkingQty'],
                             instock_supply_qty: row['InStockSupplyQuantity'],
                             reserved_orders: row['ReservedCustomerOrders'],
                             reserved_fcprocessing: row['Reserved_FCProcessing'],
                             from_remapped_sku: row['IncludesQuantitiesFromRemappedSKU']
      )

    else
      p "not found #{row['asin']}"
    end
    count
  end

end