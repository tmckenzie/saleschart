module ExhibitsHelper
  def exhibit(model)
    Object.
        const_get("#{model.class.name}Exhibit").
        new(model, self).tap do |exhibitor|
      if !self.instance_variable_defined?(:@exhibitor)
        self.instance_variable_set(:@exhibitor, exhibitor)
      end
    end
  end
end