class SalesController < ApplicationController

  def index


    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.series(:name => 'Toys', :data => [3, 20, 3, 5, 4, 10, 12, 3, 5, 6, 7, 7, 80, 9, 9])
      f.series(:name => 'Home', :data => [1, 3, 4, 3, 3, 5, 4, -46, 7, 8, 8, 9, 9, 0, 0, 9])
    end

    @pie = Charts::PieView.new.simple_pie(QueryManagers::Mock::MockQueryManager.new().sales_by_dept(1))
    # @pie = LazyHighCharts::HighChart.new('pie') do |f|
    #   f.chart({:defaultSeriesType => "pie", :backgroundColor => "transparent", :margin => [30, 30, 30, 30],
    #            :spacingTop => 0, :spacingBottom => 0, :spacingLeft => 0, :spacingRight => 0})
    #   series = {
    #       :type => 'pie',
    #       :name => '$',
    #       :data => [
    #           ['Other', 5000],
    #           ['Home', 8000],
    #           ['Toys', 10000]
    #       ]
    #   }
    #   f.series(series)
    #   f.legend(:layout => 'vertical', :itemMarginTop => 0, :itemMarginBottom => 0)
    #   f.plot_options(:pie => {
    #       :allowPointSelect => true,
    #       :cursor => "pointer",
    #       :showInLegend => true,
    #       :dataLabels => {
    #           :enabled => false
    #       }
    #   })
    # end

    @combochart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({:text => "Combination chart"})
      f.options[:xAxis][:categories] = ['Item1', 'Item2', 'Item3', 'Item4', 'Item5']
      f.labels(:items => [:html => "Total products", :style => {:left => "40px", :top => "8px", :color => "black"}])
      f.series(:type => 'column', :name => 'Sept', :data => [3, 2, 1, 3, 4])
      f.series(:type => 'column', :name => 'Oct', :data => [2, 3, 5, 7, 6])
      f.series(:type => 'column', :name => 'Nov', :data => [4, 3, 3, 9, 0])
      f.series(:type => 'column', :name => 'Dec', :data => [4, 3, 3, 9, 0])
      f.series(:type => 'spline', :name => 'Average', :data => [3, 2.67, 3, 6.33, 3.33])
      f.series(:type => 'pie', :name => 'Total consumption',
               :data => [
                   {:name => 'Sept', :y => 13, :color => 'red'},
                   {:name => 'Oct', :y => 23, :color => 'green'},
                   {:name => 'Nov', :y => 19, :color => 'blue'}
               ],
               :center => [100, 80], :size => 100, :showInLegend => false)
    end
    # new Highcharts("chart")
    #         .SetXAxis(new XAxis { Categories = new[] { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" } })
    #         .SetYAxis(new YAxis { Title = new YAxisTitle { Text = "Sales" } })
    #         .SetSeries(new Series { Data = new Data(new object[] { 20, 30, 40, 50, 20, 60, 14, 72, 30, 35, 10, 20 }), Name = "Sales" })
    #         .SetTitle(new Title { Text = "Sales Data" })
    #         .InitChart(new DotNet.Highcharts.Options.Chart { DefaultSeriesType = DotNet.Highcharts.Enums.ChartTypes.Column });
    # }

    last_year_start_date ||= Date.today.prev_year.beginning_of_year
    last_year_end_date ||= Date.today.prev_year.end_of_year
    start_date ||=  Date.today.beginning_of_year
    end_date ||=  Date.today.end_of_year

    # data = QueryManagers::Mock::MockQueryManager.new.monthly_product_sales(start_date,end_date)
    data = QueryManagers::Mysql::SqlQueryManager.new.monthly_product_sales(start_date,end_date)
    @chart3 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Sales Data #{start_date.year}")
      f.xAxis(:categories => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
      f.series(:name => "Sales", :yAxis => 0, :data => data)
      f.chart({:defaultSeriesType => "column"})
    end
    data = QueryManagers::Mysql::SqlQueryManager.new.monthly_product_sales(last_year_start_date,last_year_end_date)
    @chart4 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Sales Data #{last_year_end_date.year}")
      f.xAxis(:categories => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
      f.series(:name => "Sales", :yAxis => 0, :data => data)
      f.chart({:defaultSeriesType => "column"})
    end

    @chart2 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Sales vs Inventory")
      f.xAxis(:categories => ["Item1", "Item2", "Item3", "Item4", "Item5"])
      f.series(:name => "Sales", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
      f.series(:name => "Inventory", :yAxis => 1, :data => [310, 127, 1340, 81, 65])

      f.yAxis [
                  {:title => {:text => "Sales", :margin => 70}},
                  {:title => {:text => "Inventory"}, :opposite => true},
              ]

      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:defaultSeriesType => "column"})
    end

    # @bar_example = Charts::BarChartView.new.simple_google_bar(QueryManagers::MockQueryManager.new.sales_by_year_month(1))
  end

end