module Charts
  class PieView

    def simple_pie(pie_data)

      LazyHighCharts::HighChart.new('pie') do |f|
        f.chart({:defaultSeriesType => "pie", :backgroundColor => "transparent", :margin => [30, 30, 30, 30],
                 :spacingTop => 0, :spacingBottom => 0, :spacingLeft => 0, :spacingRight => 0})
        series = {
            :type => 'pie',
            :name => '$',
            :data => pie_data
        }
        f.series(series)
        f.legend(:layout => 'vertical', :itemMarginTop => 0, :itemMarginBottom => 0)
        f.plot_options(:pie => {
            :allowPointSelect => true,
            :cursor => "pointer",
            :showInLegend => true,
            :dataLabels => {
                :enabled => false
            }
        })
      end
    end
  end
end