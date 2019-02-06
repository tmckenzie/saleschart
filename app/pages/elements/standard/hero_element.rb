module Elements
  module Standard
    class HeroElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::HERO_RENDERER
      hideable false

      element_options do |option_builder|
        option_builder.image :background_image, shared_setting: SharedSettingType::BACKGROUND_IMAGE, configurable: false, label_hint: 'Upload an image at least 1600 by 400'
        option_builder.boolean :display_background, shared_setting: SharedSettingType::DISPLAY_BACKGROUND, configurable: false
        option_builder.image :logo, display_name: "Hero Logo", hideable: true, hide_by_default: true
        option_builder.string :message, display_name: "Headline Text", maxlength: 60, default: Proc.new{|page| "Give to your local #{page.account.name} #{page.jargon_for_team.capitalize} Today" }
        option_builder.string :search_field_placeholder_text, display_name: "Search Text Field", default: Proc.new {|page| "Search for #{page.jargon_for_team.downcase.pluralize} here"}
      end
    end
  end
end