module EmailProcessors
  class ExportContactListsPageView < ContactListSyncingFlowPageView
    def contact_lists_path
      export_contact_lists_path
    end

    def available_contact_lists
      available_export_lists.map do |list|
        {
          list_id: list.id,
          list_label: list.name,
          subscriber_count: list.subscribed_email_contacts.count,
          selected: export_contact_lists.nil? || export_contact_lists.include?(list.id.to_s)
        }
      end
    end

    def update_contact_lists
      if params[contact_list_field_name].present?
        accessible_lists = available_export_lists.map(&:id)
        lists = params[contact_list_field_name].select {|list| accessible_lists.include?(list.to_i) }
        self.export_contact_lists = lists
      else
        self.export_contact_lists = []
      end
      flash[:success] = "We've successfully updated your selection"
      true
    end

    alias_method :next_page_path, :contact_list_sync_path
  end
end