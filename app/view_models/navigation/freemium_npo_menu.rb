module Navigation
  class FreemiumNpoMenu < Menu

    def generate_main_menu_links(user)
      links = super
      links << { label: 'GiveNow Button', link: @view_context.give_now_online_gift_path, icon_class: '' }
      links << { label: 'Receipt Configuration', link: '/account#receipt_config', icon_class: '' }
      links << { label: 'Reports', submenu: reports_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Merchant Account', link: 'https://mcmerchant.cardconnect.com', icon_class: '' }
      links << { label: 'Org Settings', link: @view_context.account_url, icon_class: '' }
      links << { label: 'Tips', link: 'http://mcause.us/5', icon_class: '' }
      links
    end

    def generate_footer_links(user)
      links = []
      links << { "Terms & Conditions" => "https://www.mobilecause.com/give-now-terms-and-conditions", attrs: { target: '_blank' } }
      links
    end

    def reports_menu_links(user)
      links = []
      links << { label: 'Search Transactions', link: @view_context.search_path(Filter::FilterView::TRANSACTION_SEARCH), icon_class: '' }
      links << { label: 'Recurring Donations', link: @view_context.recurring_donations_path("donation_filter[keyword_type]" => nil), icon_class: '' }
      links << { label: 'Download Center', link: @view_context.search_path(Filter::FilterView::TRANSACTION_SEARCH), icon_class: '' }
      links
    end
  end
end
