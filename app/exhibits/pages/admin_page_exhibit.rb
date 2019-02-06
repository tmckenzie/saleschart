class Pages::AdminPageExhibit < Pages::AbstractPageExhibit
  delegate :current_user, :current_npo, to: :view
  delegate :account, to: :current_user

  attr_accessor :setup_page_called

  def initialize(*)
    super
    if !setup_page_called
      raise "#setup_page must be called on Pages::AdminPageExhibit. Make sure super is called if the method is overridden."
    end
  end

  def render_layout(&block)
    render partial: 'layouts/shared/mc_default_layout', &block
  end

  def loader(*)
    content_tag :p, align: "center", class: "padding-top--lv4 padding-bottom--lv4" do
      view.image_tag "loading-wheel.gif"
    end
  end

  def summary_panel(options)
    column xs: 12, md: 4 do
      content_tag :div, class: "well summary-panel" do
        render(options.to_hash.merge(partial: "dashboard/npo/summary_panel_header_with_icon")) + yield
      end
    end
  end

  def summary_list(options)
    component = options[:component]
    content_tag :ul, class: "summary-list list-unstyled" do
      # render(partial: "analytics_dashboard/dashboard_chart")
      render collection: component.children,
             wrapper_tag: :li,
             wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
             wrapper_html: { class: "summary-item" } do |item|
        render item.internal_name, item, options.to_hash.merge(with: item.renderer)
      end
    end
  end

  def deferred_content(component, options)
    content_tag(:span, component.label, class: "key") +
    content_tag(:span, render_async(view.deferred_dashboard_path(format: :js, key: component.key)) { "loading..."}, class: "value pull-right")
  end

  protected
  def setup_component_defaults
    # NOOP - prevent parent version of this method from running and/or raising
  end

  def setup_page
    self.setup_page_called = true

    setup_stylesheets
    setup_javascripts
    setup_content
    setup_account_status_message
    setup_nav_bar
    setup_touch_icons
    setup_modals
    setup_footer
    setup_google_tagmanager

    super
  end

  def setup_content
    define LayoutBuilder::CONTENT, wrap_all: :container, fluid: false
  end

  def setup_account_status_message
    prepend LayoutBuilder::CONTENT, partial: "modularized/flash_content"

    account_status = account.try(:account_status)
    account_message = if account_status == Account::AccountStatus::DISABLED
      "This account has been disabled.  Please contact support@mobilecause.com for questions."
    elsif account_status == Account::AccountStatus::PENDING
      "This account is pending.  Please contact support@mobilecause.com for questions."
    end
    if account_message
      prepend LayoutBuilder::CONTENT do
        content_tag :p, class: "alert alert-danger" do
          content_tag :strong, account_message
        end
      end
    end
  end

  def setup_nav_bar
    navigation_partial, body_class = ['modularized/app_nav_bar', 'beta sticky--nav']
    prepend LayoutBuilder::BODY, partial: navigation_partial
    define LayoutBuilder::BODY, wrapper_html: {  class: body_class, data: { spy: 'scroll', target: '#scroll-nav' } }
  end

  def setup_touch_icons
    append LayoutBuilder::HEAD, partial: 'modularized/touch_icons'
  end

  def setup_stylesheets
    define LayoutBuilder::STYLESHEETS do
      view.stylesheet_link_tag 'admin_build'
    end
  end

  def setup_google_tagmanager
    prepend LayoutBuilder::HEAD do
      render LayoutBuilder::GTM, partial: 'shared/google_tag_manager'
    end
    prepend LayoutBuilder::BODY, partial: 'shared/google_tag_manager_body_noscript'
  end

  def setup_javascripts
    define LayoutBuilder::JAVASCRIPTS do
      view.javascript_include_tag 'admin_build'
    end
  end

  def setup_footer
    append LayoutBuilder::BODY do
      render partial: 'modularized/application_footer'
    end
  end

  def setup_modals
    after_all CONTENT, partial: 'modularized/vendor_features'
  end
end