module Navigation
  class MCAdminMenu < Menu
    def generate_main_menu_links(user)
      links = super
      links << { label: 'Setup', submenu: @view_context.mcadmin_manage_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Reports', submenu: reports_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Messages', submenu: messages_menu_links(user), data: { toggle: 'dropdown', hover: 'dropdown', delay: '1000' } }
      links << { label: 'Call Center', link: @view_context.call_center_index_url }
      links << { label: 'Order History', link: @view_context.admin_orders_url }
      if MobileCause::Application.config.mcbilling_url.present?
        #links << { label: 'Billing', link: MobileCause::Application.config.mcbilling_url }
      end
      links
    end

    def generate_footer_links(user)
      links = super
      links << {"Ops Center" => @view_context.operations_dashboard_index_url} if user.operations_admin?
      links
    end

    def reports_menu_links(user)
      links = []
      links << { label: 'Search Transactions', link: @view_context.search_path(Filter::FilterView::TRANSACTION_SEARCH), icon_class: '' }
      links << { label: 'Pledged Donations', link: @view_context.donations_path("donation_filter[keyword_type]" => nil), icon_class: '' }
      links << { label: 'Recurring Donations', link: @view_context.recurring_donations_path("donation_filter[keyword_type]" => nil), icon_class: '' }
      links << { label: 'Download User Report', link: @view_context.user_report_admin_users_url(:format => :csv), icon_class: '' }
      links << { label: 'Download Accounts Health Report', link: @view_context.health_report_admin_analytics_url, icon_class: '' }
      links << { label: 'Download NPO Report', link: @view_context.npo_report_admin_analytics_url, icon_class: '' }
      links << { label: 'Download NPO Features', link: @view_context.npo_feature_report_admin_analytics_url, icon_class: '' }
      links << { label: 'Download Channel Partner Report', link: @view_context.channel_partner_report_admin_analytics_url, icon_class: '' }
      links << { label: 'Download Center', link: @view_context.download_requests_path, icon_class: '' }
      links
    end

    def messages_menu_links(user)
      links = []
      links << { label: 'Scheduled', link: @view_context.messages_url, icon_class: '' }
      links << { label: 'Outbox', link: @view_context.messages_url(type: Message::SENT), icon_class: '' }
      links << { label: 'Inbox', link: @view_context.messages_report_index_path, icon_class: '' }
      links << { label: 'Reminders', link: @view_context.reminders_path, icon_class: '' }
      links << { label: 'Recurring Donations', link: @view_context.recurring_donation_messages_path(scheduled: true, message_type: RecurringDonationMessage::THANKS_MESSAGE_TYPE), icon_class: '' }
      links << { label: 'MTs', link: @view_context.mobile_terminateds_path, icon_class: '' }
      links << { label: 'MOs', link: @view_context.mobile_originateds_path, icon_class: '' }
      links
    end
  end
end
