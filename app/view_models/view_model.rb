class ViewModel < SimpleDelegator
  attr_accessor :view, :model, :options

  def initialize(view:, model:, **options)
    self.view = view
    self.model = model
    self.options = options
    super view
  end

  def amount_for_display(amount)
    amount.nil? || amount == 0 ? "-" : number_to_currency(amount)
  end

  def count_for_display(count)
    number_with_delimiter(count.to_i)
  end
end