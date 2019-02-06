require 'SVG/Graph/BarHorizontal'
class DashboardController < ApplicationController

  before_filter :set_dashboard
  layout 'application'

  def index1

  end

  def index
    p "here"
    p @exhibitor.layout
   p  @exhibitor.action
    render layout: @exhibitor.layout, action: @exhibitor.action
    #    p @nav_links
    #    @h = LazyHighCharts::HighChart.new('graph') do |f|
    #      f.options[:chart][:defaultSeriesType] = "area"
    #      f.series(:name=>'Toys', :data=>[3, 20, 3, 5, 4, 10, 12 ,3, 5,6,7,7,80,9,9])
    #      f.series(:name=>'Home', :data=> [1, 3, 4, 3, 3, 5, 4,-46,7,8,8,9,9,0,0,9] )
    #    end
    #
    #    @pie = LazyHighCharts::HighChart.new('pie') do |f|
    #      f.chart({:defaultSeriesType=>"pie", :backgroundColor=>"transparent", :margin=>[30, 30, 30, 30],
    #               :spacingTop=>0, :spacingBottom=>0, :spacingLeft=>0, :spacingRight=>0})
    #      series = {
    #          :type=> 'pie',
    #          :name=> '$',
    #          :data=> [
    #              ['Other',  5000],
    #              ['Home',   8000],
    #              ['Toys',   10000]
    #          ]
    #      }
    #      f.series(series)
    #      f.legend(:layout=> 'vertical', :itemMarginTop=>0, :itemMarginBottom=>0)
    #      f.plot_options(:pie=>{
    #          :allowPointSelect=>true,
    #          :cursor=>"pointer",
    #          :showInLegend=>true,
    #          :dataLabels=>{
    #              :enabled=>false
    #          }
    #      })
    #    end
    #
    #    @combochart = LazyHighCharts::HighChart.new('graph') do |f|
    #  f.title({ :text=>"Combination chart"})
    #  f.options[:xAxis][:categories] = ['Item1', 'Item2', 'Item3', 'Item4', 'Item5']
    #  f.labels(:items=>[:html=>"Total products", :style=>{:left=>"40px", :top=>"8px", :color=>"black"} ])
    #  f.series(:type=> 'column',:name=> 'Sept',:data=> [3, 2, 1, 3, 4])
    #  f.series(:type=> 'column',:name=> 'Oct',:data=> [2, 3, 5, 7, 6])
    #  f.series(:type=> 'column', :name=> 'Nov',:data=> [4, 3, 3, 9, 0])
    #  f.series(:type=> 'column', :name=> 'Dec',:data=> [4, 3, 3, 9, 0])
    #  f.series(:type=> 'spline',:name=> 'Average', :data=> [3, 2.67, 3, 6.33, 3.33])
    #  f.series(:type=> 'pie',:name=> 'Total consumption',
    #  :data=> [
    #    {:name=>  'Sept', :y=> 13, :color=> 'red'},
    #    {:name=> 'Oct', :y=> 23,:color=> 'green'},
    #    {:name=> 'Nov', :y=> 19,:color=> 'blue'}
    #  ],
    #  :center=> [100, 80], :size=> 100, :showInLegend=> false)
    # end
    #
    #    @chart2 = LazyHighCharts::HighChart.new('graph') do |f|
    #  f.title(:text => "Sales vs Inventory")
    #  f.xAxis(:categories => ["Item1", "Item2", "Item3", "Item4", "Item5"])
    #  f.series(:name => "Sales", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
    #  f.series(:name => "Inventory", :yAxis => 1, :data => [310, 127, 1340, 81, 65])
    #
    #  f.yAxis [
    #    {:title => {:text => "Sales", :margin => 70} },
    #    {:title => {:text => "Inventory"},  :opposite => true},
    #  ]
    #
    #  f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
    #  f.chart({:defaultSeriesType=>"column"})
  end

  def dashboards

  end

  #p "here"
  #data = []
  #fields = [[74, "http://www.google.com/reader/view/"],
  # [42, "http://www.rubyflow.com/items/1606"],
  # [35, "http://www.dzone.com/links/creating_graphviz_graphs_from_ruby_arrays.html"],
  # [27, "http://www.dzone.com/links/rss/creating_graphviz_graphs_from_ruby_arrays.html"],
  # [20, "http://www.reddit.com/r/ruby/"],
  # [12, "http://www.reddit.com/r/ruby/comments/7tw1a/creating_graphviz_graphs_from_ruby_arrays/"],
  # [9, "http://www.graphviz.org/Resources.php"],
  # [8, "http://www.netvibes.com/"],
  # [8, "http://www.google.com/reader/view/#overview-page"],
  # [8, "http://www.google.com/notebook/fullpage"]]
  #
  #
  ##ARGF.each do |line|
  ##  line = line.chomp.split
  ##  data << line[0].to_i
  ##  fields << line[1]
  ##end
  #p fields
  #
  #@graph = SVG::Graph::BarHorizontal.new(:height => 20 * data.size, :width => 800, :fields => fields.reverse)
  #
  ##p "here"
  ##
  #@graph.add_data(:data => data.reverse)
  #@graph.rotate_y_labels = false
  #@graph.scale_integers = true
  #@graph.key = false
  #p @graph
  #p "here"
  #@view = @graph
  #p @graph.public_methods
  ##print @graph.burn

  # end

  #http://dashboard.demo.vaadin.com/#!dashboard
  #http://www.highcharts.com/demo/combo-multi-axes

  def set_dashboard
    p 'Set contexst'
    p current_user
    context = view_context
    # if current_user.nil?
    #   user = User.last
    #   sign_in(:user, user)
    # end
    if current_user.present? && current_user.mmp_admin?
      @dashboards = Dashboards::MMPAdminDashboard.new(context, current_user)
    elsif current_user.vendor_admin?
      @dashboards = Dashboards::VendorDashboard.new(context, current_user)
    end
    @exhibitor = context.exhibit(@dashboards) if @dashboards.present?

  end

end
