class Themes::Theme1::ThemeCrowdfundingPageExhibit < Themes::AbstractThemeForPageExhibit
  def setup_theme_for_page
    # Skip the default placement of the social media section
    #  and append mobile and desktop versions where they are meant to be on the page
    skip PageSection::SOCIAL_MEDIA_SECTION

    # Render the main section as an accordion for xs screens (hidden on larger screens)
    #  and as tabs for non-xs screens (hidden on xs screens)
    define PageSection::MAIN_SECTION, column_html: { class: "top-xlarge" } do |options|
      render({ with: ::Pages::Components::ComponentsExhibit::ACCORDION_RENDERER, mobile: true}.merge(options)) +
      render({ with: ::Pages::Components::ComponentsExhibit::TABS_RENDERER, mobile: false}.merge(options))
    end

    default_selected_tab = page_view.page.default_selected_tab
    if default_selected_tab.present? && page_view.root_fundraiser?
      append LayoutBuilder::BODY do
        content_tag :span, "", id: "page-meta-data", data: { selected_tab: default_selected_tab, selected_tab_remote_path: page_view.remote_path_for(default_selected_tab) }
      end
    end

    define Elements::Standard::FundraisersElement.internal_name,
           fundraisers: []

    define Elements::Standard::TeamsElement.internal_name,
           teams: []

    # TODO: replace this partial once the table-for gem is updated to use blocks 4.0
    define Elements::Standard::DonorsElement.internal_name,
      donors: []

    define Elements::Standard::BannerDonateButtonElement.internal_name,
      button: {
        type: :danger
      },
      to: page_view.donate_button_url,
      wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
      wrapper_html: { class: "navbar-text", id: "navbar-donate", style: "display: none" }

    append Elements::Standard::BannerDonateButtonElement.internal_name do
      " or"
    end if page_view.show_element?(Elements::Standard::BannerTextElement)

    append Elements::Standard::BannerTextElement.internal_name do
      "<br>".html_safe
    end

    prepend PageSection::RIGHT_SECTION do
      "<div class='progress-carousel-spacer hidden-md hidden-lg'></div>".html_safe
    end unless page_view.show_element?(Elements::Standard::TotalRaisedElement)

    around PageSection::STATISTICS_SECTION do |content_block|
      row &content_block
    end

    count_offsets = if !page_view.show_element?(Elements::Standard::DonorCountElement) ||
                       !page_view.show_element?(Elements::Standard::FundraiserCountElement)
      { xs: 3 }
    else
      {}
    end

    define Elements::Standard::TotalRaisedElement.internal_name,
           column_html: { class: "text-primary" },
           total_raised: 0
    append Elements::Standard::TotalRaisedElement.internal_name do
      "<div class='progress-bar-spacer hidden-xs hidden-sm'></div>".html_safe
    end unless page_view.show_element?(Elements::Standard::ProgressBarElement)

    define Elements::Standard::DonorCountElement.internal_name,
           wrapper: :column,
           xs: 6,
           offsets: count_offsets,
           column_html: { class: "text-primary" },
           donor_count: 0

    # Deferred ajax call to load donors tab, donor count and progress bar
    append LayoutBuilder::JAVASCRIPTS do
      content_tag :script, type: "text/javascript" do
        %% $(function() {
            $.get('#{page_view.remote_path_for(PageSection::STATISTICS_SECTION)}', function(data) {updateContent(null, data);});
          });
        %.html_safe
      end
    end

    define Elements::Standard::FundraiserCountElement.internal_name,
           wrapper: :column,
           xs: 6,
           offsets: count_offsets,
           column_html: { class: "text-primary" },
           fundraiser_count: 0

    define PageSection::RIGHT_SECTION,
           column_html: { class: "text-center" }
    surround PageSection::RIGHT_SECTION do |content_block|
      content_tag :div, id: "right-section", &content_block
    end

    define Elements::Standard::DonateButtonElement.internal_name,
           button: {
               type: :primary,
               size: :large,
               block: true
           },
           link_html: { id: "donate-button", data: { lightbox: page_view.page.open_page_buttons_in_lightbox, url: page_view.donate_button_url } },
           to: '#'

    define Elements::Standard::FundraiserButtonElement.internal_name,
           button: {
               type: :info,
               size: :large,
               block: true
           },
           link_html: { id: "fundraiser-button", class: "top-xlarge" },
           to: page_view.fundraiser_button_url,
           label: page_view.fundraiser_button_text

    if !page_view.root_fundraiser?
      skip PageSection::TEAMS_SECTION
      skip PageSection::FUNDRAISERS_SECTION if !page_view.team_page?
      define Elements::Standard::MainTextElement.internal_name, wrapper_html: { class: "hidden-xs" }
      before PageSection::LEFT_SECTION do
        render partial: "public/pages/components/profile" if page_view.show_personalization_banner?
      end
      after PageSection::RIGHT_SECTION do
        render partial: "public/pages/components/call_to_action"
      end

      before Elements::Standard::MainTextElement.internal_name do
        image = page_view.banner_personal_image_url.presence || "/assets/avatar.png"
        view.image_tag image, :class => "img-#{page_view.profile_picture_type} profile pull-left hidden-xs"
      end
    end

    define Elements::Standard::BannerTextElement.internal_name, with: nil do
      page_view.banner_text
    end

    body_classes = []
    if page_view.notice
      before PageSection::BANNER_SECTION do
        render Pages::Components::ComponentsExhibit::ALERT_RENDERER, type: 'info', message: page_view.notice
      end
      body_classes << "has-alerts"
    end

    if page_view.show_section?(PageSection::SOCIAL_MEDIA_SECTION)
      body_classes << "sticky-footer--sm"
      append LayoutBuilder::CONTENT, partial: "public/pages/components/share_mobile"
      append PageSection::BANNER_SECTION, partial: "public/pages/components/share_desktop"
      after LayoutBuilder::JAVASCRIPTS,
        partial: 'modularized/social_media_tracking',
        npo_id: page_view.npo_id
    end

    if !page_view.show_section?(PageSection::BANNER_SECTION)
      body_classes << "empty-banner"
      prepend LayoutBuilder::CONTENT do
        render PageSection::BANNER_SECTION
      end
    end

    if body_classes.present?
      define LayoutBuilder::BODY,
        wrapper_html: { class: body_classes.join(" ") }
    end

    around Elements::Standard::CopyrightElement.internal_name do |content_block|
      column(xs: 9, column_html: { class: "text-left padding-right-none" }) do
        with_output_buffer do
          output_buffer << content_tag(:span, class: 'padding-right-medium', &content_block)
          output_buffer << content_tag(:span, class: 'legal-links') do
            with_output_buffer do
              output_buffer << render(Elements::Custom::ButtonElement.internal_name,
                               to: "https://www.mobilecause.com/constituent-terms-new/",
                               label: "Terms",
                               with: :link_button,
                               button: false)
              output_buffer << render(Elements::Custom::ButtonElement.internal_name,
                               to: page_view.account_terms_url.presence || "https://www.mobilecause.com/privacy/",
                               label: "Privacy Policy",
                               with: :link_button,
                               button: false)
            end
          end
        end
      end +
      column(xs: 3, column_html: { class: "text-right" }) do
        terms_in_new_line = true
        buffer = ActionView::OutputBuffer.new
        if view.current_user
          if page_view.peer_fundraiser == view.current_peer_fundraiser
            buffer << render(Elements::Standard::LoginButtonElement.internal_name,
              to: page_view.edit_page_url,
              label: "Edit",
              with: :link_button,
              wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
              wrapper_tag: :span,
              wrapper_html: { class: "right-large" },
              button: false)
          end

          buffer << render(Elements::Custom::ButtonElement.internal_name,
            to: view.destroy_user_session_url(protocol: view.protocol, redirect_url: URI.escape(view.peer_fundraising_home_page_url(page_view.peer_fundraiser))),
            label: "Log Out",
            method: :delete,
            with: :link_button,
            button: false)
        elsif !page_view.root_fundraiser?
          edit_page_link_options = page_view.edit_page_link_options
          buffer << render(Elements::Custom::ButtonElement.internal_name,
            to: edit_page_link_options[:link_url],
            label: CrowdfundingPage::IS_THIS_YOUR_PAGE_LINK_TEXT,
            method: edit_page_link_options[:link_method],
            with: :link_button,
            button: false)
        else
          terms_in_new_line = false
        end
        buffer
      end
    end
  end
end
