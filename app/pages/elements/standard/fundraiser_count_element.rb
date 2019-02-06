module Elements
  module Standard
    class FundraiserCountElement < Elements::Custom::TextElement
      default_renderer Pages::Components::ComponentsExhibit::FUNDRAISER_COUNT_RENDERER
      configurable false
    end
  end
end