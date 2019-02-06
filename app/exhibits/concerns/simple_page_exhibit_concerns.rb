module SimplePageExhibitConcerns
  extend ActiveSupport::Concern

  included do
    attr_accessor :view_model
    attr_accessor :setup_page_called
  end

  def initialize(view_model:, view: view_model.view, **init_options)
    super view, init_options

    self.view_model = view_model

    setup_page

    # Ensures that if #setup_page is overridden, super is always called from it
    if !setup_page_called
      raise "#setup_page must be called on Pages::AdminPageExhibit. Make sure super is called if the method is overridden."
    end
  end

  def setup_page
    self.setup_page_called = true
  end
end