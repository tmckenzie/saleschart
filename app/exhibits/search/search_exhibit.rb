module Search
  class SearchExhibit < Blocks.builder_class
    include SimplePageExhibitConcerns

    def render_search_sections
      row do
        with_output_buffer do
          view_model.filter_sections.each do |filter_section|
            output_buffer << render(filter_section, defaults: { with: filter_section })
          end
        end
      end
    end

    # TODO: the * here should no longer be necessary in an upcoming release of Blocks 3.1.
    #  It is currently necessary because Blocks is expecting the method to take at least
    #  one argument (likely the Blocks::RuntimeContext) and is not handling the case
    #  properly when the method takes no arguments.
    def activity_filters(*)
      fields = []
      keyword_text = "Select a campaign to filters by its keywords"
      form_text = "Select a campaign and/or keyword to filters by its forms "
      if view_model.current_user.npo
        fields += [select_field(:campaign_id,"","",[], id: 'campaign_choice'), select_field(:campaigns_keyword_id, "Keyword", "", [], "", {}, keyword_text, id: 'keyword_choice' ), select_field(:form, "", "", [], "", {}, form_text)]
      else
        fields += [text_field(:campaign), text_field(:keyword)]
      end
      render_search_section(:activities, fields)
    end

    def saved_objects
      nil
    end

    private

    def render_search_section(section_name, fields, header: true, label: section_name.to_s.titleize)
      render partial: 'search/search_section', section: section_name, fields: fields, section_label: label, header: header
    end

    def text_field(name, label = '', max_length = nil, data_attributes = {})
      { name: name, label: label_text(label, name), max_length: max_length, data_attributes: data_attributes, control_type: :text_field }
    end

    def checkbox_field(name, options, label = '', radio_cb = false, grouping = false, full_width = grouping)
      control_type = grouping ? :checkbox_group_field : :checkbox_field
      { name: name, label: label_text(label, name), options: options, control_type: control_type, radio_cb: radio_cb, full_width: full_width }
    end

    def prepended_text_field(name, label = '', prepend_label = '$')
      { name: name, label: label_text(label, name), prepend_label: prepend_label, control_type: :prepended_text_field }
    end

    def select_field(name, label = '', prompt = '', options = nil, default = '', data_attributes = {}, help_label = nil, id: nil)
      { name: name, label: label_text(label, name), help_label: help_label, prompt: prompt, options: options, default: default, control_type: :select_field, data_attributes: data_attributes, id: id }
    end

    def label_text(label_text, name)
      label_text.present? ? label_text : name.to_s.titleize
    end
  end
end