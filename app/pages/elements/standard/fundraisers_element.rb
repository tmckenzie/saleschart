module Elements
  module Standard
    class FundraisersElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::FUNDRAISERS_RENDERER
      configurable false
    end
  end
end