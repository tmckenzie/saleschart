module EmailProcessors
  class LinkingFlowPageView < ConstantContactBasePageView
    def account_configured?
      [
        current_user.first_name,
        current_user.last_name,
        npo.email,
        npo.web_url,
        npo.remittance_phone,
        npo.remittance_address,
        npo.remittance_city,
        npo.remittance_state,
        npo.remittance_zip
      ].all?(&:present?)
    end

    def payment_configured?
      npo.braintree_vault_token.present?
    end

    def can_access_step?
      true
    end

    def furthest_step_path
      if !account_configured?
        configure_account_path
      elsif !payment_configured?
        configure_payment_path
      else
        new_account_path
      end
    end

    def configure_account_path
      view.configure_account_account_email_processor_constant_contact_integrations_path(params[:account_email_processor_id])
    end

    def configure_payment_path
      view.configure_payment_account_email_processor_constant_contact_integrations_path(params[:account_email_processor_id])
    end

    def new_account_path
      view.new_account_email_processor_constant_contact_integration_path(params[:account_email_processor_id])
    end

    def cancel_button_confirm
      "Are you sure you dont want to create a new email account and better engage with your audience?"
    end

    def cancel_button_confirm_title
      "Leave Linking Flow?"
    end

    def cancel_button_confirm_text
      "No, Create Later"
    end

    def cancel_button_cancel_text
      "Cancel"
    end
  end
end