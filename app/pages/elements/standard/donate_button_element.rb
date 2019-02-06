module Elements
  module Standard
    class DonateButtonElement < Elements::Custom::MultipleFormsButtonElement
      default_link_text PeerFundraiserSetting::DEFAULT_FORM_BUTTON_TEXT
      default_form_option_text 'Default Donation Form'
      form_id_options display_name: 'Donation button link',
                      label_hint: 'Choose the donation form for the main fundraising page; this does not affect individual pages'

      hideable false
    end
  end
end