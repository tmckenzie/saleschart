module EmailProcessors
  class ConstantContactBasePageView < ::Pages::StaticPageView
    include EmailProcessorIntegrationConcerns

    attr_accessor :errors

    def initialize(*)
      self.errors = []
      super
    end

    def return_to_path
      view.session[:constant_contact_return_to] ||= (params[:return_to] || view.root_path)
    end

    def account_email
      npo.email
    end

    def link_account_path
      view.account_email_processor_constant_contact_integrations_path(params[:account_email_processor_id])
    end

    def contact_list_sync_path
      view.account_email_processor_contact_list_syncs_path(params[:account_email_processor_id])
    end

    def next_page_path
      '#'
    end

    def current_path
      request.path
    end

    protected
    def npo
      @npo ||= model.account.accountable
    end

    def account_email_processor
      @account_email_processor ||= model.originable
    end

    def service
      @service ||= ConstantContactIntegrationService.new(account_email_processor, view.auth_constant_contact_callback_url(account_email_processor_id: account_email_processor.id))
    end
  end
end
