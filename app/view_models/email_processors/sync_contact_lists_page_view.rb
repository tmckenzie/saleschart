module EmailProcessors
  class SyncContactListsPageView < ContactListSyncingFlowPageView
    delegate :errors, to: :service

    def run_export_field_name
      "sync_mc_contact_lists"
    end

    def run_import_field_name
      "sync_remote_contact_lists"
    end

    def import_contact_lists_label
      element_for(SYNC_FROM_BUTTON).label
    end

    def export_contact_lists_label
      element_for(SYNC_TO_BUTTON).label
    end

    def import_contact_lists_summary
      if importing_any_contact_lists?
        "&nbsp;".html_safe
      else
        count = selected_import_lists.count
        "#{pluralize(count, 'list')}"
      end
    end

    def export_contact_count
      selected_export_lists.map {|list| list.subscribed_email_contacts.count }.sum
    end

    def export_contact_lists_summary
      contact_list_summary selected_export_lists.count, export_contact_count
    end

    def selected_export_lists(check_sync_param: false)
      if check_sync_param && params[run_export_field_name].blank?
        []
      elsif @selected_export_lists
        @selected_export_lists
      else
        selected_lists = export_contact_lists
        available_lists = available_export_lists

        @selected_export_lists = if selected_lists == []
          []
        elsif selected_lists.present?
          available_lists.select {|list| selected_lists.include?(list.id.to_s) }
        else
          available_lists
        end
      end
    end

    def selected_import_lists(check_sync_param: false)
      if check_sync_param && (params[run_import_field_name].blank? || importing_any_contact_lists?)
        []
      else
        available_import_lists
      end
    end

    def sync
      service.sync_contact_lists(
        selected_export_lists(check_sync_param: true).map(&:id),
        selected_import_lists(check_sync_param: true).map(&:id)
      )
    end

    def next_page_path
      view.synced_account_email_processor_contact_list_syncs_path(params[:account_email_processor_id])
    end

    def sync_to_message
      "*Syncing lists to Constant Contact may cause your monthly fee to change, we will not sync new contacts automatically."
    end

    def sync_from_message
      if importing_any_contact_lists?
        "You have previously chosen to sync lists from Constant Contact. This action cannot be taken again."
      else
        "**Sync lists from Constant Contact is a one time action and will not affect your monthly fee."
      end
    end

    def can_sync?
      selected_export_lists.present? || can_import?
    end

    def can_import?
      selected_import_lists.present? && !importing_any_contact_lists?
    end

    private
    def contact_list_summary(list_count, contact_count)
      "#{pluralize(list_count, 'list')} / #{pluralize(contact_count, 'contact')}"
    end
  end
end