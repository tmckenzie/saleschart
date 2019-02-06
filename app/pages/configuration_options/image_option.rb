module ConfigurationOptions
  class ImageOption < BaseOption
    def display_value(page: nil)
      if persisted? && !is_shared_setting?
        ComponentImage.find(super).image
      else
        super
      end
    rescue
      nil
    end
  end
end