module EmailProcessors
  class ContactListSyncingFlowPageView < ConstantContactBasePageView
    def available_export_lists
      @available_export_lists ||=
        ConstituentListService.new.
          list_constituent_lists(current_npo.constituent_lists).
          select {|list| list.subscribed_email_contacts.count > 0 }
    end

    def available_import_lists
      @available_import_lists ||= service.contact_lists
    end

    def importing_any_contact_lists?
      if defined?(@importing_any_contact_lists)
        @importing_any_contact_lists
      else
        @importing_any_contact_lists = account_email_processor.list_syncs.any? {|sync| sync.lists_to_sync.present? }
      end
    end

    def export_contact_lists_path
      configure_exports_account_email_processor_contact_list_syncs_path(params[:account_email_processor_id])
    end

    def export_contact_lists=(list)
      session[export_contact_lists_session_key] = list
    end

    def export_contact_lists
      if session.key?(export_contact_lists_session_key)
        session[export_contact_lists_session_key]
      else
        last_sync = account_email_processor.list_syncs.order("created_at desc").first
        message = last_sync.try(:message)
        if message
          session[export_contact_lists_session_key] = message.constituent_lists.map(&:id).map(&:to_s)
        end
      end
    end

    def cancel_button_confirm_title
      "Are you sure you want to sync later?"
    end

    def cancel_button_confirm
      %%
        In order to send messages to your contacts you must have lists with email addresses in them. In addition, syncing your lists between MobileCause and Constant Contact will ensure that your lists are in both systems and speed up the delivery of these messages in the future.<br><br>
        You can visit the Email Processors page in your account’s Settings to sync additional lists or change which lists are synced.
      %.html_safe
    end

    def cancel_button_confirm_text
      "Sync Later"
    end

    def cancel_button_cancel_text
      "Sync Now"
    end

    def contact_list_field_name
      "contact_lists"
    end

    private
    def export_contact_lists_session_key
      "email_processor_#{account_email_processor.id}_export_lists"
    end
  end
end