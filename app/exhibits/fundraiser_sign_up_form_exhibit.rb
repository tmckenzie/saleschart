class FundraiserSignUpFormExhibit < DonationFormFieldsExhibit

  def call_to_action_section_rows(section)
    rows = []
    rows <<
      {
        partial: 'public/shared/donation_form_custom_message',
        locals: {
          donation_form_settings: form_settings,
          show_message: form_settings.show_custom_message && form_settings.custom_message.present?
        }
      }
    rows
  end
end