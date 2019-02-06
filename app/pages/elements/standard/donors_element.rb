module Elements
  module Standard
    class DonorsElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::DONORS_RENDERER

      element_options do |option_builder|
        option_builder.boolean :display_donor_amount,
          only: Theme::ORIGINAL

        option_builder.toggle :donor_amount_column,
          only: Theme::THEME_1,
          default: true,
          display_name: 'Display Donor Amount'
        option_builder.toggle :fundraiser_column,
          only: Theme::THEME_1,
          default: true,
          display_name: 'Display Fundraiser Column'
        option_builder.string :fundraiser_column_label,
          only: Theme::THEME_1,
          default: PeerFundraiserSetting::DEFAULT_FUNDRAISER_COLUMN_LABEL_TEXT,
          maxlength: 12
      end
    end
  end
end