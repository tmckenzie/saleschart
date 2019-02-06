module Elements
  module Standard
    class DonorCountElement < Elements::Custom::TextElement
      default_renderer Pages::Components::ComponentsExhibit::DONOR_COUNT_RENDERER
      configurable false
    end
  end
end