module Elements
  module Standard
    class FundraiserButtonElement < Elements::Custom::MultipleFormsButtonElement
      default_link_text PeerFundraiserSetting::DEFAULT_BECOME_PEERFUNDRAISER_BUTTON_TEXT
      link_text_options display_name: 'Fundraiser Link Text'
      default_form_option_text 'Sign Up Form (default)'
      form_id_options display_name: 'Sign up button link',
                      label_hint: 'Choose the form for signing up; this will also direct team registrations to the selected form'
      element_options do |option_builder|
        option_builder.string :team_link_text,
          maxlength: 20,
          required_feature: Feature::CROWDFUNDING,
          default: Proc.new {|page| "Join This #{page.jargon_for_team}"}
      end
    end
  end
end