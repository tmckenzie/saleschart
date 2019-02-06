module Search
  class PeopleSearchExhibit < SearchExhibit

    # TODO: the * here should no longer be necessary in an upcoming release of Blocks 3.1.
    #  It is currently necessary because Blocks is expecting the method to take at least
    #  one argument (likely the Blocks::RuntimeContext) and is not handling the case
    #  properly when the method takes no arguments.
    def person_info_filters(*)
      fields = []
      fields += [
          text_field(:first_name),
          text_field(:last_name),
          text_field(:email),
          text_field(:phone),
          checkbox_field(:status, view_model.verified_mobile_number_options, 'Show only contacts with a verified mobile number', false, false, false)
      ]
      render_search_section(:contact_information, fields)
    end

    def person_location_filters(*)
      addr = {
          name: "Verified",
          checked: false,
          tooltip: "Address Verified",
          single: true,
          options: {}
      }
      fields = []
      fields += [
          text_field(:city),
          text_field(:state),
          text_field(:zip)
      ]
      render_search_section(:location, fields)
    end

    def person_donation_filters(*)
      fields = []
      fields += [prepended_text_field(:amount_min), prepended_text_field(:amount_max)]
      render_search_section(:individual_gift_amount, fields)
    end

    def render_heading(options = nil)
      super(offsets: { md: 1 }, md: 11) + row_and_column(row_html: { class: "margin-top--lv2" }, md: 10, offsets: { md: 1 }) do
        content_tag :p, class: "pull-left" do
          %%
            Search by fields and/or activities to build a new segmented list. For example,
            #{view.link_to 'search for all major donors (gave a gift above $500)', '/reports/peoples?people_filter%5Bamount_min%5D=500'}
          %.html_safe
        end
      end
    end
  end
end