class Exhibit < Blocks.builder_class
  attr_accessor :model, :context
  alias_method :context, :view

  def initialize(model, context)
    self.context = context
    self.model = model
    super context
  end

  def render_row(row)
    options = {
      partial: row[:partial],
      exhibitor: self
    }.merge(row[:locals].to_h)
    render options
  end
end