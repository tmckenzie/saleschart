class Pages::ConfigExhibit < Blocks.builder_class
  attr_accessor :view_model

  delegate :configuration_sections,
           :default_tab_options,
       to: :view_model

  def initialize(view_model, view, options = {})
    self.view_model = view_model
    super view, options
  end
end