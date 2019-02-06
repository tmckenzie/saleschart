module Pages
  class StaticPageView < ViewModel
    delegate :page_sections, :section_for, :element_for, to: :model
    alias_method :page, :model

    def initialize(*args, view: nil, model: nil, **options)
      # TODO: get rid of all view model initialize calls that pass view and
      #  model as first two args, args are for legacy calls
      view ||= args.shift
      model ||= args.shift
      super view: view, model: model, **options
    end
  end
end

