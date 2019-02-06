module ConfigurationOptions
  class BooleanOption < BaseOption
    default_value true

    def display_value(page: nil)
      StringUtil.type_cast(super, :boolean)
    end
  end
end