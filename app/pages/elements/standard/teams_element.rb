module Elements
  module Standard
    class TeamsElement < Elements::Custom::TextElement
      required_feature Feature::CROWDFUNDING
      default_renderer Pages::Components::ComponentsExhibit::TEAMS_RENDERER
      configurable false
    end
  end
end
