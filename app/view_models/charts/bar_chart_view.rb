
module Charts
  class BarChartView
    def simple_google_bar(bar_data)
      ApplicationController.new.render_to_string(template: 'sales/gchart', locals: {bar_data: bar_data})
    end
  end
end