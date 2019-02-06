module PageBuilders
  class CrowdfundingPageBuilder < BasePageBuilder
    provide_options(Elements::Standard::BannerBackgroundImageElement) do
      {
        display: element_migrator(:display_fundraising_inspirational_img?),
        image: element_migrator(:fundraising_inspirational_img)
      }
    end

    provide_options(Elements::Standard::BannerCelebrityImageElement) do
      {
        display: element_migrator(:display_seed_page_profile_img?),
        image: element_migrator(:seed_page_profile_img)
      }
    end

    provide_options(Elements::Standard::BannerTextElement) do
      {
        default_content: Proc.new {|page| StringUtil.replace_template_var("Text [keyword_string] to [shortcode_string]", page.originable) }
      }
    end

    provide_options(Elements::Standard::ProgressBarElement) do
      {
        show_donors_link: element_migrator(:display_donors?),
        display: element_migrator(:display_progress_bar?)
      }
    end

    provide_options(Elements::Standard::DonateButtonElement) do
      {
        link_text: element_migrator(:custom_form_button_text),
        form_id: element_migrator(:donation_form_id)
      }
    end

    provide_options(Elements::Standard::BannerDonateButtonElement) do
      {
        form_id: element_migrator(:donation_form_id)
      }
    end

    provide_options(Elements::Standard::FundraiserButtonElement) do
      {
        display: element_migrator(:display_fundraiser_button?),
        link_text: element_migrator(:become_fundraiser_button_text),
        form_id: element_migrator(:signup_form_id)
      }
    end

    provide_options(Elements::Standard::OrganizationLogoElement) do
      {
        display: element_migrator(:display_organization_img?)
      }
    end

    provide_options(Elements::Standard::LoginButtonElement) do
      {
        display: element_migrator(:display_login?)
      }
    end

    provide_options(Elements::Standard::TitleTextElement) do
      {
        default_content: Proc.new {|page| "<h1>#{page.account.name}</h1>"}
      }
    end

    provide_options(Elements::Standard::MainVideoElement) do
      {
        video_url: "https://youtu.be/qJVK3yyBluo"
      }
    end
  end
end