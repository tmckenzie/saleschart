module Elements
  module Standard
    class ShareButtonElement < Elements::Custom::ButtonElement
      configurable false
      link_text_options default_value: "Share"
    end
  end
end