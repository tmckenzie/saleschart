module EmailProcessors
  class ConstantContactConfigureAccountPageExhibit < LinkingBasePageExhibit
    def setup_page
      around COMPONENTS do |content_block|
        view.form_tag view_model.current_path, method: :put, &content_block
      end

      define WIZARD_NEXT_BUTTON, with: :submit_button, link_html: { id: "verifyAccount" }

      define SAVE_MESSAGE,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :label,
        wrapper_html: { class: "padding-bottom--lv4 padding-top--lv1" }

      define :input_text,
        with: :inline_input_editor,
        input_html: { name: Proc.new {|component| "account[#{component.internal_name}]" } }

      define MAIN_SECTION,
        wrapper: :column,
        xs: 12,
        sm: 8,
        md: 6,
        lg: 5,
        offsets: { sm: 2, md: 3, lg: 4 }

      define GREETING_MESSAGE,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :p,
        wrapper_html: { class: "margin-bottom--lv5" }

      define FIRST_NAME_FIELD, input_html: { value: view_model.account_first_name }
      define LAST_NAME_FIELD, input_html: { value: view_model.account_last_name }
      define EMAIL_FIELD, input_html: { value: view_model.account_email }
      define WEBSITE_FIELD, input_html: { value: view_model.account_website }
      define PHONE_NUMBER_FIELD, input_html: { value: view_model.account_phone_number }
      define ADDRESS_FIELD, with: :inline_address_input_editor

      super # must be called
    end
  end
end