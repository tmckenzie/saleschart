module Elements
  module Standard
    class ProgressBarElement < Elements::BaseElement
      default_renderer :progress_bar

      element_options do |option_builder|
        option_builder.collection RENDERER_OPTION,
          # removing progress_circle since the current plugin is not playing well with our ajax callback.
          # items: [:progress_bar, :progress_circle],
          items: [:progress_bar],
          except: Theme::ORIGINAL
        option_builder.boolean :show_donors_link,
          only: Theme::ORIGINAL
        option_builder.string :donors_link_text,
          only: Theme::ORIGINAL,
          maxlength: 20
        option_builder.boolean :show_goal
        option_builder.boolean :show_total_raised,
          only: Theme::ORIGINAL
        option_builder.color :color, shared_setting: SharedSettingType::BRAND_COLOR
      end
    end
  end
end