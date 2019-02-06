class Pages::Components::ComponentsExhibit < SimpleDelegator
  IMAGE_RENDERER = "image"
  VIDEO_RENDERER = "video"
  LINK_BUTTON_RENDERER = "link_button"
  CUSTOM_MESSAGE_RENDERER = "custom_message"
  COPYRIGHT_RENDERER = "copyright"
  PROGRESS_BAR_RENDERER = "progress_bar"
  PROGRESS_CIRCLE_RENDERER = "progress_circle"
  COMMENTS_RENDERER = "comments"
  SHARE_RENDERER = "share"
  FACEBOOK_META_TAGS = "facebook_meta_tags"
  DONORS_RENDERER = "donors"
  FUNDRAISERS_RENDERER = "cards/fundraiser_cards"
  TEAMS_RENDERER = "cards/team_cards"
  TOTAL_RAISED_RENDERER = "total_raised_label"
  DONOR_COUNT_RENDERER = "donor_count_label"
  FUNDRAISER_COUNT_RENDERER = "fundraiser_count_label"
  CAROUSEL_RENDERER = "carousel_renderer"
  CAROUSEL_ITEM_RENDERER = "carousel_item_renderer"
  LOADING_RENDERER = "loader_renderer"
  CARDS_RENDERER = "cards/cards"
  HERO_RENDERER = "hero_renderer"
  ALERT_RENDERER = "alert_renderer"
  ACCORDION_RENDERER = "accordion_renderer"
  TABS_RENDERER = "tabs_renderer"

  PAGE_ELEMENT_RENDERERS = [
    IMAGE_RENDERER,
    VIDEO_RENDERER,
    LINK_BUTTON_RENDERER,
    CUSTOM_MESSAGE_RENDERER,
    COPYRIGHT_RENDERER,
    PROGRESS_BAR_RENDERER,
    PROGRESS_CIRCLE_RENDERER,
    COMMENTS_RENDERER,
    SHARE_RENDERER,
    DONORS_RENDERER,
    FUNDRAISERS_RENDERER,
    TEAMS_RENDERER,
    TOTAL_RAISED_RENDERER,
    DONOR_COUNT_RENDERER,
    FUNDRAISER_COUNT_RENDERER,
    CAROUSEL_RENDERER,
    CAROUSEL_ITEM_RENDERER,
    LOADING_RENDERER,
    CARDS_RENDERER,
    HERO_RENDERER,
    ALERT_RENDERER,
    ACCORDION_RENDERER,
    TABS_RENDERER
  ]

  def initialize(page_exhibit)
    super page_exhibit

    standard_elements = Dir.glob("#{Rails.root}/app/pages/elements/standard/*").select {|f| f.ends_with?("element.rb")}.map {|f| "Elements::Standard::#{f.split("/").last.gsub(".rb", "").classify}".constantize.display_name }
    custom_elements = Dir.glob("#{Rails.root}/app/pages/elements/custom/*").select {|f| f.ends_with?("element.rb")}.map {|f| "Elements::Custom::#{f.split("/").last.gsub(".rb", "").classify}".constantize.display_name }
    all_page_elements = standard_elements + custom_elements
    all_page_sections = PageSection.constants.select {|c| c.to_s.ends_with?("SECTION") }.map {|c| PageSection.const_get(c).to_sym }
    intersection = all_page_elements & all_page_sections
    if intersection.present?
      raise "Page Elements and Page Sections are sharing block names: #{intersection.join(", ")}"
    end
  end

  def setup_component_defaults
    page_components_path = "public/pages/components"

    PAGE_ELEMENT_RENDERERS.each do |component|
      define component, partial: "#{page_components_path}/#{component.to_s.downcase.gsub("_renderer", "").gsub(" ", "_")}"
    end

    page_elements.each do |block_name, element|
      define block_name, with: element.renderer
    end

    page_section_names.each do |section_name|
      define section_name, defaults: {
        partial: "#{page_components_path}/page_section"
      }
    end
  end
end