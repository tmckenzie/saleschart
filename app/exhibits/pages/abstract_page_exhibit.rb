class Pages::AbstractPageExhibit < Blocks.builder_class
  attr_accessor :page_view, :theme

  alias_method :view_model, :page_view

  def loader(*)
    render Pages::Components::ComponentsExhibit::LOADING_RENDERER
  end

  def initialize(page_view, view = page_view.view)
    super view

    self.page_view = page_view

    setup
  end

  delegate :page_sections,
           :page_elements,
           :page_section_names,
           to: :page_view

  def render_page_section(section_name)
    @theme.render_section(section_name)
  end

  def custom_message(options)
    component = options[:component]
    options[:content] || component.content.try(:html_safe)
  end

  def image(options)
    component = options[:component]
    url = component.image.url(:large)
    view.image_tag url, options[:image_html].to_h.to_hash if url.present?
  end

  def link(*, options)
    component = options[:component]
    view.link_to component.link_text, options[:url] || component.url, options[:link_html].to_h.to_hash
  end
  alias_method :link_button, :link

  def page_section(options)
    section = options[:component]
    ActionView::OutputBuffer.new.tap do |output_buffer|
      section.children.each do |child_element|
        output_buffer << render(child_element.name, component: child_element, defaults: { with: child_element.renderer })
      end
    end
  end

  def inline_input_editor(options, &block)
    component = options[:component]

    content_tag :div, concatenating_merge({ class: "wrapper--input wrapper--input__inline_edit #{component.internal_name.underscore}" }, options[:input_wrapper_html], component) do
      buffer = content_tag :label, component.label, for: component.internal_name
      buffer << content_tag(:a, content_tag(:i, ""), concatenating_merge({ href: '', class: 'edit' }, options[:edit_link_html]))
      buffer << content_tag(:a, content_tag(:i, ""), concatenating_merge({ href: '', class: 'revert' }, options[:revert_link_html]))
      buffer << content_tag(:i, "", class: 'updating')
      if block_given?
        buffer << yield
      else
        input_html = {
          disabled: true,
          id: component.internal_name,
          type: component.input_type
        }
        input_html[:required] = true if component.required?
        input_html[:maxlength] = component.maxlength if component.maxlength
        input_html[:minlength] = component.minlength if component.minlength
        input_html[:pattern] = component.pattern if component.pattern
        input_html[:placeholder] = component.placeholder if component.placeholder
        buffer << view.tag(:input, concatenating_merge(input_html, options[:input_html], component))
      end
      buffer << content_tag(:div, "", class: 'feedback')
      buffer << content_tag(:div, "", class: 'message')
      if component.hint
        buffer << content_tag(:p, component.hint, class: "help-block")
      end
      buffer
    end
  end

  def inline_address_input_editor(options)
    component = options[:component]
    field_prefix = "account[#{component.internal_name.underscore}]"
    render(with: :inline_input_editor, component: component, input_wrapper_html: { class: "addressInputWrapperInlineEdit" }) do
      with_output_buffer do
        output_buffer <<
          view.tag(:input,
                   type: "text",
                   class: "address_1 margin-bottom--lv3",
                   name: "#{field_prefix}[address]",
                   value: view_model.account_address_1,
                   required: true,
                   disabled: true,
                   tabindex: 1,
                   placeholder: "Address 1")
        output_buffer <<
          view.tag(:input,
                   type: "text",
                   class: "address_2",
                   name: "#{field_prefix}[address_2]",
                   disabled: true,
                   tabindex: 1,
                   value: view_model.account_address_2,
                   placeholder: "Address 2")
        output_buffer << row do
          output_buffer <<
            column(xs: 12, sm: 5) do
              view.tag(:input,
                       type: "text",
                       class: "city margin-top--lv3",
                       name: "#{field_prefix}[city]",
                       required: true,
                       disabled: true,
                       tabindex: 1,
                       value: view_model.account_city,
                       placeholder: "City")
            end
          output_buffer <<
            column(xs: 12, sm: 4) do
              view.select_tag("#{field_prefix}[state]",
                view.options_for_state_select(view_model.account_state, "State"),
                required: true,
                disabled: true,
                tabindex: 1,
                class: "state margin-top--lv3")
            end
          output_buffer <<
            column(xs: 12, sm: 3) do
              view.tag(:input,
                       type: "text",
                       class: "zip margin-top--lv3",
                       name: "#{field_prefix}[zip]",
                       value: view_model.account_zip,
                       required: true,
                       disabled: true,
                       tabindex: 1,
                       pattern: "\\d{5}",
                       placeholder: "Zip")
          end
        end
      end
    end
  end

  def input_checkbox(options)
    component = options[:component]
    content_tag :div, class: "checkbox" do
      content_tag :label do
        view.tag(:input, concatenating_merge({ type: :checkbox, id: component.internal_name.underscore, name: component.internal_name.underscore }, options[:input_html])) + component.label
      end
    end
  end

  def input_text(options)
    component = options[:component]
    content_tag :div, class: "wrapper--input" do
      input_html = {
        id: component.internal_name.underscore,
        name: component.internal_name.underscore,
        type: component.input_type,
        data: {}
      }
      input_html[:maxlength] = component.maxlength if component.maxlength
      input_html[:pattern] = component.pattern if component.pattern
      input_html[:required] = component.required
      buffer = content_tag :label, component.label, for: component.internal_name.underscore
      buffer << view.tag(:input, concatenating_merge(input_html, options[:input_html], component))
      buffer << content_tag(:div, "", class: 'message')
      if component.hint
        buffer << content_tag(:p, component.hint, class: "help-block")
      end
      buffer
    end
  end

  def submit_button(options)
    content_tag :button, concatenating_merge(options[:link_html], type: "submit") do
      content_tag(:span, class: 'visible-xs') do
        content_tag(:i, '', aria: { hidden: "true" }, class: "fa fa-angle-right")
      end +
      content_tag(:span, options[:link_text] || options[:component].link_text, class: "hidden-xs")
    end
  end

  def errors(options)
    if view_model.respond_to?(:errors) && view_model.errors.present?
      error = view_model.errors.first
    elsif view.flash['error']
      error = view.flash['error']
    end

    if error.present?
      alert(type: 'error', icon: 'fa-exclamation-circle') do
        error
      end
    end
  end

  protected

  def setup_theme
    @theme = "Themes::#{page_view.theme.classify}::ThemeExhibit".
              constantize.new(self)
  end

  def setup_page
    view_model.page_sections.each do |page_section|
      append COMPONENTS do
        render page_section.name, component: page_section, defaults: { with: :page_section }
      end
    end
  end

  def setup_component_defaults
    ::Pages::Components::ComponentsExhibit.new(self).setup_component_defaults
  end

  private
  def setup
    setup_theme if page_view.respond_to?(:theme) && page_view.theme
    setup_page
    setup_component_defaults
  end
end
