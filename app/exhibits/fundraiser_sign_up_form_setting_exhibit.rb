class FundraiserSignUpFormSettingExhibit < DonationFormSettingExhibit

  def call_to_action_section_rows(section)
    rows = []
    section_title = 'Call To Action'
    section_id = 'panel_call_to_action_section'
    @section_titles << [section_title, section.id]
    rows <<
      {
        partial: 'donation_form_settings/custom_message_section',
        locals: {
          donation_form_setting: model,
          f: @form,
          section: section,
          section_title: section_title,
          section_id: section_id,
          tooltip: "",
          show_rich_text_editor: @current_npo.has_rich_text_editing_feature?,
        }
      }
    rows
  end
end