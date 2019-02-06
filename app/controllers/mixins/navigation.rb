module Mixins::Navigation

  def mcadmin_manage_links(user = current_user)
    links = []
    links << { label: 'Vendors', link: admin_vendors_url, icon_class: '' }
    # links << { label: 'API Partners', link: channel_partners_url, icon_class: '' }
    # links << { label: 'Resellers', link: resellers_url, icon_class: '' }
    # links << { label: 'mc-master', link: '/mc_billing', icon_class: '' } if user.mcmaster_admin?
    # links << { label: 'Global Donors', link: admin_constituents_url, icon_class: '' }
    # links << { label: 'Users', link: admin_users_url, icon_class: '' }
    # if user.operations_admin?
    #   links << { label: 'Shortcodes', link: admin_shortcodes_url, icon_class: '' }
    # end
    # links << { label: 'Keywords', link: admin_keywords_url, icon_class: '' }
    # links << { label: 'Reminder Messages', link: admin_reminders_configurations_url, icon_class: '' }
    # links << { label: 'Campaign Templates', link: admin_campaign_templates_url, icon_class: '' }
    links
  end


end