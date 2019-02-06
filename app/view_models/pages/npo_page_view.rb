module Pages
  class NpoPageView < AccountPageView
    def login_button_url
      "login"
    end

    def login_button_text
      "Login To My Page"
    end

    def show_card_subtitle?
      false
    end
  end
end

