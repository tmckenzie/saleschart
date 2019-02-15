require 'active_support/concern'

module QueryManagers
  module Mock
    module MockSalesConcern
      extend ActiveSupport::Concern

      def sales_by_year_month(vendor_id)
        mock_year_txns()
      end

      def sales_by_dept(vendor_id)
        mock_dept_total()
      end

      def mock_year_txns()
        [
            ["July 2017", 346.0],
            ["July 2016", 50.0],
        ]
      end

      def mock_dept_total
        [
            ['Other', 5000],
            ['Home', 8000],
            ['Toys', 10000]
        ]
      end
      def monthly_product_sales(start, end_date)
        [20, 30, 40, 50, 20, 60, 14, 72, 30, 35, 10, 20]
      end
    end
  end
end