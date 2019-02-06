class Themes::OriginalTheme::ThemeCrowdfundingPageExhibit < Themes::AbstractThemeForPageExhibit
  def setup_theme_for_page
    before LayoutBuilder::STYLESHEETS do
      render partial: "#{theme_path}/crowdfunding_css"
    end

    setup_banner
    setup_main
    setup_footer
    skip PageSection::SOCIAL_MEDIA_SECTION

    if page_view.notice
      prepend LayoutBuilder::BODY do
        render Pages::Components::ComponentsExhibit::ALERT_RENDERER, type: 'info', message: page_view.notice
      end
    end
  end

  protected

  def setup_back_button(url)
    before LayoutBuilder::CONTENT do
      render wrapper: :row_and_column,
             column_html: {class: 'background-lighter-grey text-center'},
             with: :link_button,
             to: url,
             label: '',
             button: nil,
             link_html: {class: "fa fa-arrow-left fundraiser_back_button"}
    end
  end

  def setup_banner
    define Elements::Standard::BannerBackgroundImageElement.internal_name do end

    if page_view.show_banner_background_image?
      define Elements::Standard::BannerBackgroundImageElement.internal_name,
             wrapper: :content_tag,
             defaults: {wrapper_html: {class: "fundraiser_background"}}
    else
      before PageSection::BANNER_IMAGES_SECTION do
        content_tag :div, nil, class: "fundraiser_empty_row"
      end
    end

    surround PageSection::BANNER_IMAGES_SECTION do |content_block|
      content_tag :table, class: "fundraiser_banner" do
        content_tag :tr do
          content_block.call
        end
      end
    end
    define Elements::Standard::BannerLogoElement.internal_name,
           wrapper: :content_tag,
           wrapper_tag: :td,
           wrapper_html: { class: "fundraiser_logo" } do end
    define Elements::Standard::BannerCelebrityImageElement.internal_name,
           wrapper: :content_tag,
           wrapper_tag: :td,
           wrapper_html: { class: "fundraiser_user_image" } do end
  end

  def setup_main
    swap_in_theme_specific_partials(Elements::Standard::ProgressBarElement.internal_name)

    define Elements::Standard::MainTextElement.internal_name,
           wrapper: lambda { |content_block, options|
             row_and_column row_html: {class: "top-xlarge bottom-xlarge"} do
               content_tag :div, class: "fundraiser_user_message text-center", &content_block
             end
           }

    define PageSection::CALL_TO_ACTION_BUTTONS_SECTION,
           wrapper: :row,
           row_html: {class: "padding-top-xlarge"}

    define Elements::Standard::DonateButtonElement.internal_name,
           wrapper: :column,
           with: :link_button,
           to: page_view.donate_button_url,
           label: page_view.donate_button_text,
           button: {
               block: true,
               size: :large
           },
           link_html: {class: "btn-fundraiser"}

    define Elements::Standard::FundraiserButtonElement.internal_name,
           wrapper: :column,
           with: :link_button,
           to: page_view.fundraiser_button_url,
           label: page_view.fundraiser_button_text,
           button: {
               block: true,
               size: :large
           },
           link_html: {class: "btn-fundraiser hollow"}

    define Elements::Standard::ShareButtonElement.internal_name,
           wrapper: :column,
           with: :link_button,
           to: page_view.share_button_url,
           button: {
               block: true,
               size: :large
           },
           link_html: {class: "btn-fundraiser hollow"} do
      (content_tag :i, "", class: "fa fa-share-square-o") + "Share"
    end

    show_join = page_view.show_element?(Elements::Standard::FundraiserButtonElement)
    show_share = page_view.show_element?(Elements::Standard::ShareButtonElement)
    show_donate = page_view.show_element?(Elements::Standard::DonateButtonElement)

    if show_join && show_share
      define Elements::Standard::FundraiserButtonElement.internal_name, sm: 9, xs: 12
      define Elements::Standard::ShareButtonElement.internal_name, sm: 3, xs: 12, column_html: { class: "padding-left-none-sm" }
    end

    skip PageSection::ORGANIZATION_SECTION if !page_view.show_organization_logo?

    surround PageSection::ORGANIZATION_SECTION do |content_block|
      row_and_column row_html: { class: "top-xlarge" } do
        content_tag :div, class: "fundraiser_footer_box", &content_block
      end
    end

    define Elements::Standard::OrganizationLogoElement.internal_name,
      wrapper: :content_tag,
      wrapper_html: { class: "fundraiser_footer_logo" },
      image_html: { class: "right-large" }

    define Elements::Standard::OrganizationSummaryElement.internal_name,
      wrapper: :content_tag,
      wrapper_html: { class: "fundraiser_footer_text" },
      wrapper_tag: :div

    skip Elements::Standard::DonorsElement.internal_name

    define Elements::Standard::ProgressBarElement.internal_name,
      goal: page_view.fundraising_goal,
      total: page_view.fundraising_total,
      progress: page_view.fundraising_progress
  end

  def setup_footer
    surround PageSection::FOOTER_SECTION do |content_block|
      column do
        content_tag :div, class: "fundraiser_mc_footer", &content_block
      end
    end

    surround Elements::Standard::LoginButtonElement.internal_name do |content_block|
      content_tag :div, class: "fundraiser_container" do
        row &content_block
      end
    end

    if page_view.root_fundraiser?
      skip Elements::Standard::LoginButtonElement.internal_name
    else
      edit_page_link_options = page_view.edit_page_link_options
      define Elements::Standard::LoginButtonElement.internal_name,
             to: edit_page_link_options[:link_url],
             label: edit_page_link_options[:link_text],
             method: edit_page_link_options[:link_method],
             button: {
                 block: true,
                 type: :default
             }
    end

    after Elements::Standard::LoginButtonElement.internal_name do
      row_and_column column_html: { class: "top-medium bottom-xlarge" } do
        link_to "Logout", view.destroy_user_session_url(redirect_url: URI.escape(view.peer_fundraising_home_page_url(page_view.peer_fundraiser))), method: :delete, class: 'text--footer-link text--xs text--footer-logout'
      end
    end if page_view.peer_fundraiser && view.current_user

    after Elements::Standard::LoginButtonElement.internal_name do
      row_and_column column_html: {class: "top-medium bottom-xlarge"} do
        view.form_for :peer_fundraiser, url: view.submit_for_review_volunteer_peer_fundraiser_path(page_view.peer_fundraiser), method: :put do |f|
          f.submit "Submit For Review", class: 'fundraiser-login-button'
        end
      end
    end if page_view.show_submit_for_review_button?
  end
end
