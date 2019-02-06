class Pages::AccountPageExhibit < Pages::AbstractPageExhibit
  def setup_page
  end

  def render_components(*component_names)
    components = {}
    component_names.each{ |name| components[name] = page_view.page.send("#{name}_element") }
    page_view.page_layout.build_page_elements(*components.values)
    html = []
    components.each do |component_name, page_element|
      html << send("render_#{component_name}_component", page_element)
    end
    html
  end

  def render_cards_component(cards_element)
    render(cards_element.internal_name, cards: page_view.cards, component: cards_element, with: cards_element.renderer)
  end
end
