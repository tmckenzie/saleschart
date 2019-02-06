module Navigation
  class CallCenterMenu < Menu
    def generate_main_menu_links(user)
      links = super
      links << { label: 'Call Center', link: @view_context.call_center_index_url, icon_class: '' }
      links
    end
  end
end