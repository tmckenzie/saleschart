module EmailProcessors
  class ImportContactListsPageView < ContactListSyncingFlowPageView
    def contact_lists_path
      import_contact_lists_path
    end

    def available_contact_lists
      available_import_lists.map do |list|
        {
          list_id: list.id,
          list_label: list.name,
          subscriber_count: list.contact_count,
          selected: import_contact_lists.nil? || import_contact_lists.include?(list.id)
        }
      end
    end

    def update_contact_lists
      if params[contact_list_field_name].present?
        accessible_lists = available_import_lists.map(&:id)
        lists = params[contact_list_field_name].select {|list| accessible_lists.include?(list) }
        self.import_contact_lists = lists
      else
        self.import_contact_lists = []
      end
      flash[:success] = "We've successfully updated your selection"
      true
    end

    alias_method :next_page_path, :contact_list_sync_path
  end
end