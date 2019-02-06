module EmailProcessors
  class ConstantContactAccountPageView < LinkingFlowPageView
    delegate :errors, to: :service

    def account_username
      params[:username] || account_email
    end

    def create_account
      if service.create_account(view.current_user, params[:username], params[:password])
        flash[:success] = "We've created your account. To get started sending emails, let's sync your contacts."
      end
    end

    def link_account
      if params[:code]
        service.process_access_code(params[:code], params[:username])
        flash[:success] = "We've linked your account. To get started sending emails, let's sync your contacts."
        true
      end
    end

    def constant_contact_oauth_login_path
      service.login_url
    end

    def create_account_path
      view.account_email_processor_constant_contact_integrations_path(params[:account_email_processor_id])
    end

    def link_existing_account?
      params[:action] == "login"
    end

    def can_access_step?
      if link_existing_account?
        true
      else
        account_configured? && payment_configured?
      end
    end

    alias_method :next_page_path, :contact_list_sync_path
  end
end

