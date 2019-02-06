class ViewModelCollection < Array
  attr_accessor :view, :collection

  def initialize(view:, collection:, view_model_class:, **options)
    collection = collection.map do |model|
      view_model_class.new(view: view, model: model, **options)
    end

    super collection
  end
end