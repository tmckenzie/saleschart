module EmailProcessors
  class ConstantContactAccountPageExhibit < LinkingBasePageExhibit
    def setup_page
      define USERNAME_FIELD,
        input_html: { value: view_model.account_username }

      define WIZARD_NEXT_BUTTON, with: :submit_button, link_html: { id: "createAccount" }

      around COMPONENTS do |content_block|
        view.form_tag view_model.create_account_path, autocomplete: "off", &content_block
      end

      define MAIN_SECTION,
        wrapper: :column,
        xs: 12,
        md: 6,
        lg: 4,
        offsets: { md: 3, lg: 4 }
      # must be called
      super
    end
  end
end