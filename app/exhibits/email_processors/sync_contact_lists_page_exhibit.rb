module EmailProcessors
  class SyncContactListsPageExhibit < SyncingBasePageExhibit
    def setup_page
      around COMPONENTS,
        with: FORM_TAG_COMPONENT,
        form_html: { id: 'sync_contacts_form' },
        url: view_model.current_path

      if view.flash['success']
        prepend WIZARD_NAVIGATION_SECTION, with: ALERT_COMPONENT, message: view.flash['success'], type: "success", alert_html: { class: 'margin-top--lv2 margin-bottom--lv0 alert--success'}
      end

      define GREETING_MESSAGE,
        wrapper: :column,
        column_html: { class: 'text-center margin-bottom--lv5' }

      define WIZARD_NEXT_BUTTON,
        with: :submit_button,
        link_html: {
          id: "syncAccount",
          disabled: !view_model.can_sync?,
          data: {
            contact_count: view_model.export_contact_count,
            list_count: view_model.selected_export_lists.count
          }
        }

      define :input_checkbox,
        with: :sync_option,
        wrapper: :column,
        md: 6

      define SYNC_OPTIONS_SECTION,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_html: { class: 'btn__group', 'data-toggle' => 'buttons' }

      define SYNC_TO_BUTTON,
        title: 'Sync to Constant Contact*',
        name: view_model.run_export_field_name,
        sub_title: view_model.export_contact_lists_summary,
        disabled: view_model.available_export_lists.empty?,
        sub_action_url: view_model.export_contact_lists_path,
        selected: view_model.selected_export_lists.present?

      append SYNC_TO_BUTTON do
        content_tag :div, class: 'text-center text--muted text--sm' do
          view_model.sync_to_message
        end
      end

      define SYNC_FROM_BUTTON,
        title: 'Sync from Constant Contact',
        name: view_model.run_import_field_name,
        sub_title: view_model.import_contact_lists_summary,
        disabled: !view_model.can_import?,
        selected: view_model.can_import?,
        changeable: false,
        sync_icon_html: 'icon--sync-from'

      append SYNC_FROM_BUTTON do
        if view_model.importing_any_contact_lists?
          alert(message: view_model.sync_from_message, type: :info, icon: nil, dismissible: false)
        else
          content_tag :div, class: 'text-center text--muted text--sm' do
            view_model.sync_from_message
          end
        end
      end

      define MAIN_SECTION,
        xs: 12,
        md: 8,
        lg: 6,
        offsets: { md: 2, lg: 3, },
        wrapper: :column
      super # must be called
    end

    def sync_option(options)
      render({
        partial: 'components/sync_option',
        defaults: {
          selected: true,
          disabled: false,
          local_icon_html: { alt: 'MobileCause', src: '/assets/icons/mc_logo_primary.svg' },
          remote_icon_html: { alt: 'ConstantContact', src: '/assets/icons/ctct_logo_flag.svg' },
          sync_icon_html: 'icon--sync-to',
          name: 'SYNC_OPTION_NAME',
          title: 'SET TITLE',
          sub_title: 'SET SUBTITLE',
          sub_action_label: 'Change',
          sub_action_url: '#',
          changeable: true
        }
      }.deep_merge(options.to_hash))
    end
  end
end
