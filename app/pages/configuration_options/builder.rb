module ConfigurationOptions
  class Builder
    attr_accessor :page_element, :options

    def initialize(page_element=nil)
      self.page_element = page_element
      self.options = []
    end

    def method_missing(name, *args)
      option_class = "ConfigurationOptions::#{name.to_s.classify}Option".constantize
      args = [page_element].compact + args
      option = option_class.new(*args)
      self.options << option
      if option.hideable?
        self.options << ConfigurationOptions::ToggleOption.new("show_#{option.name}", configurable: false, default_value: option.hide_by_default?)
      end
    end
  end
end