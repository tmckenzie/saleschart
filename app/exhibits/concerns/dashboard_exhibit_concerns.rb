module DashboardExhibitConcerns
  # TODO: Remove the * here once Blocks is upgraded to 3.1
  def back_button(*)
    path, text = if view.params.key?(:back_path)
      [view.params[:back_path], "Back to #{view.params[:referrer].try(:titleize)}"]
    else
      [view.root_path, "Back to Dashboard"]
    end
    view.link_to path, class: 'breadcrumb' do
      "<i class='fa fa-chevron-left padding-right--lv1'></i> #{text}".html_safe
    end
  end
  BACK_BUTTON = instance_method(:back_button).name

  def render_breadcrumbs(options={})
    # TODO: switch this to simply render BACK_BUTTON ... once upgraded to Blocks 3.1
    offset_options = options[:offsets] || { md: 1 }
    render with: BACK_BUTTON,
      wrapper: :row_and_column,
      row_html: { class: "margin-top--lv3" },
      md: 10,
      offsets: offset_options
  end
  BREADCRUMBS = instance_method(:render_breadcrumbs).name

  # TODO: Remove the * here once Blocks is upgraded to 3.1
  def render_action_dropdown_menu(*, &block)
    content_tag(:div, class: 'dropdown') do
      with_output_buffer do
        output_buffer << view.link_to('#', class: 'dropdown-toggle', data: { toggle: 'dropdown' }) do
          with_output_buffer do
            output_buffer << content_tag(:i, '', class: 'fa fa-circle dots') + " "
            output_buffer << content_tag(:i, '', class: 'fa fa-circle dots') + " "
            output_buffer << content_tag(:i, '', class: 'fa fa-circle dots')
          end
        end
        output_buffer << content_tag(:ul, class: "dropdown-menu dropdown-menu-left", &block)
      end
    end
  end
  ACTION_DROPDOWN_MENU = instance_method(:render_action_dropdown_menu).name

  def render_heading(options={}, &block)
    page_title = options[:page_title] || view_model.page_title
    icon_class = options[:icon_class] || view_model.icon_class
    row row_html: { class: "margin-top--lv2" } do
      column options do
        with_output_buffer do
          output_buffer << view.content_tag(:span, class: 'form__label-icon pull-left') do
            view.content_tag(:i, '', class: "mc #{icon_class}")
          end
          output_buffer << view.content_tag(:h1, page_title, class: 'dashboard__title pull-left')
          output_buffer << view.capture(&block) if block_given?
        end
      end
    end
  end
  HEADING = instance_method(:render_heading).name
end