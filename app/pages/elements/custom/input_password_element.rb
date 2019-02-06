module Elements
  module Custom
    class InputPasswordElement < InputElement
      default_renderer :input_text
      default_input_type :password
    end
  end
end