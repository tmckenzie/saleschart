class ActivityExhibit < AdminExhibit
  attr_accessor :model
  attr_reader :page

  NAVIGATION = :navigation
  PAGE = :page
  HEADER = :header
  BREADCRUMBS = :breadcrumbs
  SOCIAL_MEDIA_SETTINGS = "social-form"

  alias_method :context, :view
  delegate :params, to: :view

  def initialize(model, view)
    self.model = model
    super
    config_page_navigation
    options_set.add_options section_locals

    define SOCIAL_MEDIA_SETTINGS,
      partial: "activities/social_media"

    setup_components
  end

  def render_row(row)
    options = {
      partial: row[:partial],
      exhibitor: self
    }.merge(row[:locals].to_h)
    render options
  end

  def section_locals
    {
      id: page.current_page_section.try(:id),
      heading: page.current_page_section.try(:heading),
      campaigns_keyword: campaigns_keyword
    }
  end

  def layout
    "private/default_layout"
  end

  protected

  def setup_online_forms
    if page.current_page_section.panel_id.present?
      donation_form_setting = DonationFormSetting.find_by_id(page.current_page_section.panel_id)
    end
    # get the default donation form if none
    donation_form_setting = campaigns_keyword.default_form unless donation_form_setting
    partial = "activities/setup_online_forms"
    {
      partial: partial,
      locals: {
        activity_config: model.activity_config,
        campaigns_keyword: campaigns_keyword,
        donation_form_setting: donation_form_setting
      }.merge(section_locals)
    }
  end

  def new?
    ['new', 'create'].include? params[:action]
  end

  def config_page_navigation
    @page = Navigation::Page.new(referrer: params[:referrer])
    @page.page_url = view.edit_activity_path(campaigns_keyword) unless new?
  end

  def setup_components
    setup_breadcrumbs
    setup_header
    setup_navigation
    setup_page_components

    define COMPONENTS,
      wrap_all: :row
  end

  def setup_breadcrumbs
    link = back_link

    define BREADCRUMBS,
      wrapper: :column,
      column_html: { class: 'margin-top--lv4' } do
      view.link_to back_link[:link_path], class: 'breadcrumb' do
        content_tag(:i, '', class: 'fa fa-chevron-left padding-right-small') +
        " Back to #{back_link[:link_text]}"
      end
    end
    if back_link
      append COMPONENTS do
        render BREADCRUMBS
      end
    end
  end

  def setup_header
    define HEADER,
      partial: 'activities/form_sections_heading',
      model: model,
      wrapper: :column,
      sm: 8,
      md: 9,
      lg: 10,
      offsets: { sm: 4, md: 3, lg: 2 },
      column_html: { class: "margin-top--lv2" }

    append COMPONENTS do
      render HEADER
    end
  end

  def setup_navigation
    define NAVIGATION,
      partial: "activities/side_navigation",
      page: page,
      wrapper: :column,
      sm: 4,
      md: 3,
      lg: 2

    append COMPONENTS do
      render NAVIGATION
    end
  end

  def setup_page_components
    prepend PAGE,
      partial: 'modularized/form_errors',
      errors: model.activity_config.errors

    page_options = {
      exhibitor: self,
      wrapper: :column,
      sm: 8,
      md: 9,
      lg: 10
    }
    define PAGE, page_options
    if current_page_section.action && self.respond_to?(current_page_section.action, true)
      current_page = send(current_page_section.action)
      if current_page.is_a?(Hash)
        define(PAGE,
          current_page[:locals].to_h.merge(partial: current_page[:partial])
        )
      end
    end
    append COMPONENTS do
      render PAGE
    end
  end

  def back_link
    case params[:referrer]
      when 'campaign'
        campaign_param = campaigns_keyword.try(:campaign).try(:id) || params[:campaign_id]
        if campaign_param.blank? && params[:activity].present?
          campaign_param = params[:activity][:campaign_id]
        end
        campaign_param.present? ? { link_text: 'Campaign', link_path: view.campaign_keywords_path(campaign_param) } : {}
      when 'thermometer'
        { link_text: 'Thermometer', link_path: view.graph_settings_path }
      when 'givelater'
        { link_text: 'Give Later', link_path: view.widgets_activities_path }
      when 'mobile_pledging', 'mobile_messaging', 'social_giving', 'auction'
        { link_text: Navigation::NpoMenu.keyword_title_from(params[:referrer]), link_path: view.activities_path(type: params[:referrer]) }
      when *FormType.available_types
        { link_text: FormType.friendly_name(params[:referrer]), link_path: view.donation_form_settings_path(form_type: params[:referrer]) }
      else
        { link_text: 'Dashboard', link_path: view.root_path }
    end
  end

  def campaigns_keyword
    model.activity_config.campaigns_keyword
  end

  def current_page_section
    if @current_page_section
      @current_page_section
    else
      @current_page_section = page.current_page_section = page.find_section_by(params[:section]) || page.current_page_section
      @current_page_section.panel_id = params[:panel]
      @current_page_section
    end
  end
end