module ConfigurationOptions
  class CollectionOption < BaseOption
    def grouped?
      !!options[:grouped]
    end

    def items
      if options[:items].is_a?(Proc)
        call_with_params options[:items], page_element
      elsif options[:items].first.is_a?(Array)
        options[:items]
      else
        options[:items].map {|item| [item.to_s.titleize, item]}
      end
    end
  end
end