module EmailProcessors
  class ExportContactListsPageExhibit < SyncingBasePageExhibit
    def setup_page
      around COMPONENTS,
        with: FORM_TAG_COMPONENT,
        url: view_model.export_contact_lists_path,
        method: :put

      define WIZARD_NEXT_BUTTON,
        with: :submit_button,
        link_html: { id: "updateContactLists" }

      define CONTACT_LIST_SELECTOR,
        list_html: { data: {
          remote_url: view_model.contact_lists_path,
          input_field_name: view_model.contact_list_field_name
        } }

      define WIZARD_CANCEL_BUTTON,
        link_html: { data: nil },
        with: :link_to,
        label: view_model.element_for(WIZARD_CANCEL_BUTTON).link_text,
        path: view_model.contact_list_sync_path

      super # must be called
    end
  end
end
