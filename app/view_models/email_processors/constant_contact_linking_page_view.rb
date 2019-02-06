module EmailProcessors
  class ConstantContactLinkingPageView < LinkingFlowPageView
    alias_method :next_page_path, :configure_account_path

    def link_existing_account_path
      view.login_account_email_processor_constant_contact_integrations_path(account_email_processor_id: params[:account_email_processor_id])
    end
  end
end
