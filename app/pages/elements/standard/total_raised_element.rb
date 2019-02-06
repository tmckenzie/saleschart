module Elements
  module Standard
    class TotalRaisedElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::TOTAL_RAISED_RENDERER
      configurable true
      element_options do |option_builder|
        option_builder.string :label,
          maxlength: 15,
          shared_setting: SharedSettingType::GOAL_MEASUREMENT_LABEL
      end
    end
  end
end
