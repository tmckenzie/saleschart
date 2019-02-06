module EmailProcessors
  class ConstantContactConfigureAccountPageView < LinkingFlowPageView
    def update_account
      account = params[:account]

      if account
        first_name, last_name, email, website, phone_number, address =
        account[:first_name], account[:last_name], account[:email], account[:website], account[:phone_number], account[:address]
      end

      if first_name || last_name
        if first_name
          current_user.update_attributes(first_name: first_name)
        end
        if last_name
          current_user.update_attributes(last_name: last_name)
        end
        self.errors += current_user.errors.full_messages
      end

      if email || website
        if email
          npo.update_attributes(email: email)
        end
        if website
          npo.update_attributes(web_url: website)
        end
        self.errors += npo.errors.full_messages
      end

      if phone_number
        npo.update_remittance_contact(phone_number: phone_number)
        self.errors += npo.remittance_contact.errors.full_messages
      end

      if address.present?
        npo.update_remittance_contact(address)
        self.errors += npo.remittance_contact.errors.full_messages
      end

      errors.empty?
    end

    def account_first_name
      current_user.first_name
    end

    def account_last_name
      current_user.last_name
    end

    def account_website
      url = npo.web_url
      if url && !url.starts_with?("http")
        "http://#{url}"
      else
        url
      end
    end

    def account_phone_number
      npo.remittance_phone
    end

    def account_address_1
      npo.remittance_address
    end

    def account_address_2
      npo.remittance_address_2
    end

    def account_city
      npo.remittance_city
    end

    def account_state
      npo.remittance_state
    end

    def account_zip
      npo.remittance_zip
    end

    alias_method :next_page_path, :configure_payment_path
    alias_method :current_path, :configure_account_path
  end
end

