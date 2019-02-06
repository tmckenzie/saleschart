module Navigation
  class ChannelPartnerMenu < Menu
    def generate_main_menu_links(user)
      links = super
      links << { label: 'Fundraising', submenu: setup_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Reports', submenu: reports_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links
    end

    def get_edit_user_url
      @view_context.edit_account_settings_url
    end

    def reports_menu_links(user)
      links = []
      links += super
      links << { label: 'Consolidated Constituent List', link: @view_context.consolidate_constituent_lists_path, icon_class: '' } if @view_context.mc_admin?
      links
    end

    private

    def setup_menu_links(user)
      links = []
      #links << {"Visit My Landing Page" => user.account.account_home_page_vanity_url}
      links << { label: 'Landing Page', link: @view_context.edit_home_page_account_path, icon_class: '' }
      links
    end
  end
end