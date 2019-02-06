class Pages::CrowdfundingPageExhibit < Pages::AbstractPageExhibit
  def setup_page
    after LayoutBuilder::CSRF do
      render Pages::Components::ComponentsExhibit::FACEBOOK_META_TAGS, object: page_view
    end

    define LayoutBuilder::TITLE do
      view.page_title(nil, page_view.campaigns_keyword.campaign.npo.short_name)
    end

    define Elements::Standard::MainTextElement.internal_name,
      wrapper_tag: :div,
      wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK,
      wrapper_html: { class: "bottom-xlarge"}

    define Elements::Standard::OrganizationSummaryElement.internal_name,
      wrapper_tag: :div,
      wrapper: Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK

    define Elements::Standard::MainTextElement.internal_name do
      page_view.main_text_html
    end

    define Elements::Standard::ProgressBarElement.internal_name,
      goal: page_view.fundraising_goal,
      total: 0,
      progress: 0
  end
end
