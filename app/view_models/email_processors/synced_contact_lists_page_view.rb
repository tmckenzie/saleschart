module EmailProcessors
  class SyncedContactListsPageView < ContactListSyncingFlowPageView
    def send_email_path
      message_builder_path
    end

    def communication_center_path
      new_message_path
    end
  end
end
