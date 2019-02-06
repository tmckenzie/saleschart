module EmailProcessors
  class ConstantContactLinkingPageExhibit < LinkingBasePageExhibit
    def setup_page
      define MAIN_SECTION,
        container_html: { class: 'container--scrollable__navbar_only' }
      define LINK_NEW_ACCOUNT, url: view_model.next_page_path
      define LINK_EXISITING_ACCOUNT, url: view_model.link_existing_account_path

      define GREETING_MESSAGE,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :h1,
        wrapper_html: { class: 'text-center' },
        wrap_all: :column

      define PRICING_MESSAGE,
        wrapper: :column,
        column_html: { class: 'text-center padding-top--lv4' }

      append PRICING_MESSAGE do |options|
        view.link_to options[:component].display_name, 'javascript: alert("Open Modal here")'
      end

      define LINK_EXISITING_ACCOUNT,
        wrapper: :column,
        column_html: { class: 'text-center padding-top--lv1' }

      append LINK_EXISITING_ACCOUNT do |options|
        view.link_to options[:component].display_name, options[:url]
      end

      define LINK_NEW_ACCOUNT,
        wrapper: :column,
        column_html: { class: 'text-center padding-top--lv4' },
        link_html: { class: 'btn btn--primary', id: "createNew" }

      after MAIN_SECTION do
        column column_html: { class: 'text-center padding-top--lv6' } do
          view.link_to "#{content_tag :i, '', class: 'fa fa-angle-left'} Back".html_safe, view_model.return_to_path, class: 'btn btn--link'
        end
      end

      # must be called
      super
    end
  end
end