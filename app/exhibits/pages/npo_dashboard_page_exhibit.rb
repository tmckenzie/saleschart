class Pages::NpoDashboardPageExhibit < Pages::NpoAdminPageExhibit
  def layout
    "admin"
  end

  def action
    "../pages/show"
  end

  def setup_page
    if view_model.npo.has_main_dashboard_analytics_feature? && view_model.npo.has_main_dashboard_analytics_js_feature?
      prepend LayoutBuilder::HEAD, partial: 'modularized/sisense_main_scripts_head'
      append LayoutBuilder::BODY do
        render partial: 'modularized/sisense_main_scripts_body'
      end
    end

    after_all CONTENT, partial: 'modularized/new_activity_modal'

    define ::Pages::AdminPageExhibit::COMPONENTS, wrap_all: :row

    if view_model.npo.has_main_dashboard_analytics_feature?
      if view_model.npo.has_main_dashboard_analytics_js_feature?
        define NpoDashboardPage::TOTAL_DONATIONS_PANEL,
             partial: 'analytics_dashboard/main_dashboard'
      else
        define NpoDashboardPage::TOTAL_DONATIONS_PANEL,
               partial: 'analytics_dashboard/main_dashboard_iframe'
      end

      skip_completely NpoDashboardPage::DONATIONS_PANEL
      skip_completely NpoDashboardPage::SUBSCRIPTIONS_PANEL
      skip_completely NpoDashboardPage::TRAINING_VIDEOS_PANEL
    end

    define NpoDashboardPage::DONATIONS_PANEL,
           wrap_all: :summary_panel,
           name: "Donations",
           icon: "fa-credit-card",
           with: :summary_list

    define NpoDashboardPage::SUBSCRIPTIONS_PANEL,
           wrap_all: :summary_panel,
           name: "Subscriptions",
           icon: "fa-rss",
           with: :summary_list

    define NpoDashboardPage::TRAINING_VIDEOS_PANEL,
           wrapper: :summary_panel,
           name: "Training Videos",
           icon: "fa-television" do |options|
      component = options[:component]
      content_tag :ul, class: "list-unstyled" do
        render collection: component.children,
               as: :component,
               with: :link,
               wrapper_tag: :li,
               link_html: { target: "_blank" },
               wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
               wrapper_html: { class: "bottom-small" }
      end
    end

    define DashboardPage::CAMPAIGNS, with: :render_campaign_cards, defaults: { async: true }
    define DashboardPage::KEYWORDS, with: :render_keywords_table, defaults: { async: true }

    prepend NpoDashboardPage::TABBED_PANEL do
      content_tag :div, class: "pull-right" do
        with_output_buffer do
          output_buffer << render(partial: 'dashboard/npo/filter_menu')
          output_buffer << render(partial: 'dashboard/npo/sort_menu')
          output_buffer << render(partial: 'messages/send_a_message_dropdown')
          output_buffer << content_tag(:button, "New Activity", class: "btn btn-info", type: 'button', data: { toggle: 'modal', target: '#new-activity-modal' })
        end
      end
    end

    define NpoDashboardPage::TABBED_PANEL, wrapper: :column do |options|
      section = options[:component]
      tabs tabs_wrapper_html: { class: "legacy__tabs", id: "dashboard-tabbed-content" } do |tab_builder|
        section.children.each_with_index do |child_element, index|
          tab_builder.tab child_element.display_name, active: index == 0, tab_html: { class: 'remoteTabContent', data: { path: view_model.path_for(child_element.internal_name) } } do
            render(child_element.internal_name, component: child_element, defaults: { with: child_element.renderer })
          end
        end
      end
    end

    super
  end

  def send_deferred_key(key)
    key_sym = key.to_sym
    return unless known_deferred_methods.include?(key_sym)
    send key_sym
  end

  def total_collected_amount
    view.number_to_currency(view_model.total_collected_amount, precision: 0)
  end

  def total_offline_amount
    view.number_to_currency(view_model.total_offline_amount, precision: 0)
  end

  def total_pending_amount
    view.number_to_currency(view_model.total_pending_amount, precision: 0)
  end

  def total_pledged_amount
    view.number_to_currency(view_model.total_pledged_amount, precision: 0)
  end

  def total_donors
    view.number_with_delimiter(view_model.total_donors)
  end

  def total_messages_sent_this_month
    view.number_with_delimiter(view_model.total_messages_sent_this_month)
  end

  def total_messages_sent
    view.number_with_delimiter(view_model.total_messages_sent)
  end

  def total_subscribers
    view.number_with_delimiter(view_model.total_subscribers)
  end

  protected
  def known_deferred_methods
    [
      :total_messages_sent_this_month,
      :total_messages_sent,
      :total_subscribers,
      :total_collected_amount,
      :total_offline_amount,
      :total_pending_amount,
      :total_donors
    ]
  end
end
