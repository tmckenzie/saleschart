class Themes::OriginalTheme::ThemeCrowdfundingTeamPageExhibit < Themes::OriginalTheme::ThemeCrowdfundingPageExhibit
  def setup_theme_for_page
    define PageSection::BANNER_SECTION,
      partial: 'public/themes/original/components/carousel',
      images: page_view.team_banner_images

    prepend PageSection::MAIN_SECTION do
      row do
        content_tag(:h2, page_view.team_display_name) +
        content_tag(:div, page_view.fundraiser_name, class: "text-center") +
        content_tag(:hr)
      end
    end

    define Elements::Standard::MainTextElement.internal_name,
      wrapper: lambda { |content_block, options|
        content_tag :div, class: "fundraiser_footer_box" do
          buffer = if page_view.fundraiser_avatar.present?
            view.image_tag page_view.fundraiser_avatar, class: 'right-large'
          else
            view.image_tag 'avatar.png', width: '9rem', height: '9rem', class: 'right-large'
          end
          buffer << content_tag(:div, class: "fundraiser_user_message team_member_message", &content_block)
        end
      }

    define Elements::Standard::DonateButtonElement.internal_name,
      link_html: { class: "btn-team" }
    define Elements::Standard::FundraiserButtonElement.internal_name,
      link_html: { class: "btn-team hollow" }
    define Elements::Standard::ShareButtonElement.internal_name,
      link_html: { class: "btn-team hollow" }

    super
  end
end
