module Navigation
  class PageSection
    ATTRIBUTES =
        [
            :id, :heading, :url, :position, :action, :default, :panel_id
        ]

    attr_accessor *ATTRIBUTES

    def initialize(attributes={})
      set_attributes(attributes)
    end

    def set_attributes(attributes)
      if attributes
        ATTRIBUTES.each do |attribute|
          next if attributes[attribute].nil?
          send("#{attribute}=", attributes[attribute])
        end
      end
    end

    def <=>(other)
      result = nil
      if other.is_a?(ViewModels::Navigation::PageSection)
        result = if self.position == other.position
                   0
                 elsif self.position > other.position
                   1
                 else
                   -1
                 end
      end
      result
    end
  end
end