module EmailProcessors
  class ConstantContactConfigurePaymentPageView < LinkingFlowPageView
    delegate :errors, :braintree_params, to: :braintree_service

    alias_method :next_page_path, :new_account_path

    def update_payment_method
      braintree_service.process_braintree_response(view.request.query_string)
    end

    def credit_card_number
      if credit_card
        "****#{credit_card.last_4}"
      end
    end

    def credit_card_number_field_name
      "customer[credit_card][number]"
    end

    def credit_card_cvv
      if credit_card
        "***"
      end
    end

    def credit_card_cvv_field_name
      "customer[credit_card][cvv]"
    end

    def credit_card_zipcode(use_original: false)
      if braintree_params.present? && !use_original
        braintree_params[:customer][:credit_card][:billing_address][:postal_code]
      elsif credit_card
        credit_card.billing_address.postal_code
      end
    end

    def credit_card_zipcode_field_name
      "customer[credit_card][billing_address][postal_code]"
    end

    def credit_card_expiration(use_original: false)
      if braintree_params.present? && !use_original
        braintree_params[:customer][:credit_card][:expiration_date]
      elsif credit_card
        "#{credit_card.expiration_month}/#{credit_card.expiration_year.last(2)}"
      end
    end

    def credit_card_expiration_field_name
      "customer[credit_card][expiration_date]"
    end

    def credit_card_processor_path
      Braintree::TransparentRedirect.url
    end

    def credit_card_customer_information
      url = view.update_payment_account_email_processor_constant_contact_integrations_url(params[:account_email_processor_id])
      ERB::Util.html_escape(npo.remittance_info.generate_braintree_tr_data url)
    end

    def save_card_text
      if credit_card
        "Verify Card"
      else
        "Save Card"
      end
    end

    def save_card_title
      if credit_card
        "Verify Payment Information"
      else
        "Enter Payment Information"
      end
    end

    def can_access_step?
      account_configured?
    end

    protected
    def braintree_service
      @braintree_service ||= BraintreeService.new(npo)
    end

    def credit_card
      if defined?(@credit_card)
        @credit_card
      else
        @credit_card = if npo.braintree_vault_token
          begin
            braintree_service.find_credit_card npo.braintree_vault_token
          rescue
            nil
          end
        end
      end
    end
  end
end

