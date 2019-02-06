module Pages
  class AccountPageView < PageView
    delegate :cards_element, :display_color_overlay, to: :page
    delegate :progress_bar_color, to: :cards_element

    def account_service
      @account_service ||= AccountService.new
    end

    def edit_url
      view.edit_home_page_account_path
    end

    def can_edit_page?
      view.can? :manage, page
    end

    def cards
      account_service.search_account_objects(
        page.originable,
        pagination_options.merge(
          search_for_name: search_for,
          order_by: sort_by,
          order: order
        )
      )
    end

    def hide_banner_logo?
      !page.display_brand_logo
    end
  end
end

