module Elements
  module Standard
    class LoginButtonElement < Elements::Custom::ButtonElement
      link_text_options default_value: CrowdfundingPage::IS_THIS_YOUR_PAGE_LINK_TEXT
    end
  end
end