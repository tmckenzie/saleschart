module EmailProcessors
  class SyncedContactListsPageExhibit < SyncingBasePageExhibit
    def setup_page
      define MAIN_SECTION,
        wrapper: :column,
        xs: 12,
        md: 6,
        offsets: { md: 3 },
        column_html: { class: "text-center" },
        container_html: { class: 'container--scrollable__navbar_only' },
        row_html: { class: '' }

      before MAIN_SECTION, partial: 'shared/components/mountain_with_clouds'

      define GREETING_MESSAGE,
        wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :h1,
        wrapper_html: { class: "text-center padding-top--lv5" }
      define INSTRUCTIONS,
        wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :p
      skip SEND_EMAIL # TEMPORARY
      define SEND_EMAIL,
        link_html: { class: "btn btn--primary" },
        wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
        url: view_model.send_email_path
      define COMMUNICATION_CENTER,
        url: view_model.communication_center_path

      super # must be called
    end
  end
end
