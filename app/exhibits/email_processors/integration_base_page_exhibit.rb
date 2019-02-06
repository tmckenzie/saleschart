module EmailProcessors
  class IntegrationBasePageExhibit < ::Pages::NpoAdminPageExhibit
    include EmailProcessorIntegrationConcerns

    def setup_page
      define WIZARD_NEXT_BUTTON, url: view_model.next_page_path

      prepend WIZARD_NAVIGATION_SECTION, with: :errors

      define :inline_input_editor, defaults: {
        edit_link_html: { tabindex: 1 },
        revert_link_html: { tabindex: 1 },
        input_html: { tabindex: 1 },
        input_wrapper_html: {
          class: "inputWrapperInlineEdit"
        }
      }
      define :input_checkbox, defaults: { input_html: { tabindex: 1 } }
      define :input_text, defaults: { input_html: { tabindex: 1 } }

      around WIZARD_NAVIGATION_SECTION do |content_block|
        content_tag :div, class: 'navbar navbar--builder', role: "navigation" do
          container fluid: true do
            content_tag :ul, class: 'nav nav--tabs nav--fullwidth navbar-left', &content_block
          end
        end
      end

      define CONTACT_LIST_SELECTOR,
        wrapper: :row_and_column,
        row_html: { class: 'container--content full-height padding-top--lv4 '},
        md: 6,
        offsets: { md: 3 },
        list_html: { class: 'listing', id: 'contactLists' },
        input_group_html: { class: 'margin-bottom--lv4' },
        with: FILTER_LIST_COMPONENT

      define WIZARD_NEXT_BUTTON,
        wrap_all: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :li,
        wrapper_html: { class: 'pull-right' },
        link_html: { class: "btn btn--continue", tabindex: 2 }

      define WIZARD_CANCEL_BUTTON,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :li,
        wrapper_html: { class: 'pull-right' },
        link_html: {
          class: "btn btn--link",
          id: 'cancel',
          data: {
            confirm: view_model.cancel_button_confirm,
            confirm_title: view_model.cancel_button_confirm_title,
            confirm_button_text: view_model.cancel_button_confirm_text,
            cancel_button_text: view_model.cancel_button_cancel_text,
            confirm_url: view_model.return_to_path
          },
          tabindex: 3
        } do |options|
        content_tag :button, options[:link_html] do
          content_tag(:span, class: 'visible-xs') do
            content_tag(:i, '', aria: { hidden: "true" }, class: "fa fa-reply")
          end +
          content_tag(:span, options[:link_text] || options[:component].link_text, class: "hidden-xs")
        end
      end

      around WIZARD_TITLE do |content_block|
        content_tag :li, role: 'presentation', class: 'active' do
          content_tag :h1, class: 'navbar--title', &content_block
        end
      end

      define MAIN_SECTION,
        wrap_all: :container,
        fluid: true,
        container_html: { class: 'container--scrollable', role: 'document' },
        outer_wrapper: :row,
        row_html: { class: "container--content full-height padding-top--lv6" }#,

      surround MAIN_SECTION do |content_block|
        row &content_block
      end

      define JAVASCRIPTS do
        view.javascript_include_tag 'mc-gen-email-linking'
      end

      define STYLESHEETS do
        view.stylesheet_link_tag 'mc-gen-email-linking'
      end

      super # must be called
    end

    def setup_nav_bar
      prepend BODY, partial: 'shared/components/nav_minimal'
    end

    def setup_content
      # NOOP
    end

    def setup_footer
      # NOOP
    end
  end
end