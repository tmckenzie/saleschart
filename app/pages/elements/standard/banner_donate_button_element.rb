module Elements
  module Standard
    class BannerDonateButtonElement < DonateButtonElement
      default_link_text "Donate"
      hideable true
      form_id_options configurable: false

      # Form id should match what is set on the banner donate button
      def form_id
        page.donate_button_element.form_id
      end
    end
  end
end