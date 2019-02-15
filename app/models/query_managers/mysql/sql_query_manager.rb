module QueryManagers
  module Mysql
    class SqlQueryManager

      def self.new_instance
        if Rails.env.development?
          MockQueryManager.new
        else
          SqlQueryManager.new
        end
      end

      def monthly_product_sales(start_date, end_date)
        date_greater_than =" where product_sales.sales_date > '#{start_date}'"
        date_less_than ="and product_sales.sales_date <= '#{end_date}'"

        rows = ProductSale.find_by_sql(<<-SQL
          SELECT DATE_FORMAT(sales_date, '%Y%m') AS "year_month",
           DATE_FORMAT(sales_date, '%m') AS "month",
            sum(amount) AS "amount"
          FROM product_sales
         
      #{date_greater_than}
        #{date_less_than}
          GROUP BY 1
          ORDER BY 1
        SQL
        )
        ret = []
        (1..12).each do |i|
          month = format("%.2d", i)
          row = find_month_row(rows, month)
          if row.present?
            ret << row['amount']
          else
            ret << 0
          end
        end
        ret
      end

      def find_month_row(rows, month)
        ret = nil
        rows.each do | row|
          p row
          if row['month'] == month
            ret = row
          end
        end
        ret
      end

      def product_sales_by_year_month(product_id, start_date = nil, end_date = nil)

        date_greater_than =" and product_sales.sales_date > '#{start_date}'" if start_date.present?
        date_less_than ="and product_sales.sales_date <= '#{end_date}'" if end_date.present?

        format_str = "%Y%m"

        ProductSale.find_by_sql(<<-SQL
          SELECT DATE_FORMAT(sales_date, '%Y%m') AS "year_month",
            sum(amount) AS "amount"
          FROM product_sales
          where product_id = #{product_id}
        #{date_greater_than}
        #{date_less_than}
          GROUP BY 1
          ORDER BY 1,2
        SQL
        ).map do |row|
          [
              Date.strptime(row['year_month'], format_str).strftime("%B %Y"),
              row.amount.to_f,
          ]
        end
      end

      private

    end
  end
end