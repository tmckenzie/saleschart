module Elements
  module Custom
    class ButtonElement < LinkElement
      button true
      default_renderer :link_button
    end
  end
end