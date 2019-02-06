class Cards::FundraiserCardExhibit < Cards::CardExhibit
  alias_method :fundraiser, :model

  delegate :page_view, to: :parent_builder

  def render_component(options={}, &block)
    options = options.with_indifferent_access
    render options.merge(partial: "shared/components/card") do |builder, runtime_context|
      yield builder, runtime_context if block_given?

      if runtime_context[:card_type] == :list
        setup_list_card(runtime_context)
      elsif runtime_context[:card_style] == "descriptive"
        setup_descriptive_card(runtime_context)
      else
        setup_basic_card(runtime_context)
      end

      # setup overlay link
      prepend CARD_BLOCK do
        view.link_to card_path, class: "card__overlay", target: "_blank" do
          content_tag :span, "Go to #{StringUtil.capitalize_first_letters(view.display_fundraiser_name(fundraiser))}", class: "sr-only"
        end
      end

      # Setup card image
      define CARD_IMAGE_BLOCK, image_html: { class: "img-#{page_view.profile_picture_type}" }
      if fundraiser.personal_img.present?
        define CARD_IMAGE_BLOCK, image: fundraiser.personal_img(:large)
      end

      # Setup card title
      define CARD_TITLE_BLOCK, title: StringUtil.capitalize_first_letters(view.display_fundraiser_name(fundraiser))

      # Setup card action
      page_name = fundraiser.first_name.present? && fundraiser.first_name.length < 10  ? "View #{fundraiser.first_name.titleize}'s Page" : "View Page"
      define CARD_ACTION_BLOCK, with: :link_to, label: page_name, path: card_path, link_html: { class: "btn", target: "_blank" }
    end
  end

  private

  def setup_list_card(runtime_context)
    define CARD_BLOCK, with: CARD_LIST_STYLE, card_html: { class: "card__fundraisers--list--basic updateProgressBar" }
    define CARD_DETAILS_BLOCK, with: :card_text_to_give, keyword: fundraiser.personal_keyword, shortcode: fundraiser.shortcode_string
    if fundraiser.peer_fundraiser_team
      team = fundraiser.peer_fundraiser_team
      define CARD_ACTION_BLOCK, label: team.name, link_html: { class: "text-danger" }, path: view.volunteer_fundraiser_teams_link_url(team.campaigns_keyword.shortcode.url_node.to_s, team.campaigns_keyword.keyword_string, team.name)
    else
      skip CARD_ACTION_BLOCK
    end

    total = if quantity_goal_type?
      quantity_sold
    else
      view.currency_display(raised_amount)
    end
    append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: total_raised_label, value: total, card_stat_html: { class: "amountRaised" }

    if fundraiser.campaigns_keyword.has_fundraising_goal?
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Donors", value: fundraiser.donation_count
      if quantity_goal_type?
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal", value: goal_amount, card_stat_html: { class: "goalAmount" }
      else
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal Amount", value: view.currency_display(goal_amount), card_stat_html: { class: "goalAmount" }
      end
    else
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "", value: ""
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Donors", value: fundraiser.donation_count
      define CARD_STATS_BLOCK, wrapper_html: {style: 'margin-top: 10px'}
      skip CARD_PROGRESS_BLOCK
    end
  end

  def setup_descriptive_card(runtime_context)
    if fundraiser.peer_fundraiser_team
      team = fundraiser.peer_fundraiser_team
      append CARD_TITLE_BLOCK do
        content_tag :h5 do
          link_to team.display_name, view.volunteer_fundraiser_teams_link_url(team.campaigns_keyword.shortcode.url_node.to_s, team.campaigns_keyword.keyword_string, team.name), class: "text-danger", target: "_blank"
        end
      end
    end

    define CARD_BLOCK, card_html: { class: "card__fundraisers--#{runtime_context[:card_type]}--modern updateProgressBar"}
    define CARD_DETAILS_BLOCK do
      view.content_tag :p, view.strip_tags(fundraiser.call_to_action).try(:gsub, "&nbsp;", "")
    end
    total = if quantity_goal_type?
      quantity_sold
    else
      view.currency_display(raised_amount)
    end
    append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: total_raised_label, value: total, card_stat_html: { class: "amountRaised" }
    if fundraiser.campaigns_keyword.has_fundraising_goal?
      if quantity_goal_type?
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal", value: goal_amount, card_stat_html: { class: "goalAmount" }
      else
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal Amount", value: view.currency_display(goal_amount), card_stat_html: { class: "goalAmount" }
      end
    else
      skip CARD_PROGRESS_BLOCK
    end
  end

  def setup_basic_card(runtime_context)
    define CARD_BLOCK, card_html: { class: "card__fundraisers--#{runtime_context[:card_type]}--basic updateProgressBar" }
    define CARD_DETAILS_BLOCK, with: :card_text_to_give, keyword: fundraiser.personal_keyword, shortcode: fundraiser.shortcode_string
    skip CARD_PROGRESS_BLOCK
    total = if quantity_goal_type?
      quantity_sold
    else
      view.currency_display(raised_amount)
    end
    append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: total_raised_label, value: total, card_stat_html: { class: "amountRaised" }
    if fundraiser.campaigns_keyword.has_fundraising_goal?
      if quantity_goal_type?
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal", value: goal_amount, card_stat_html: { class: "goalAmount" }
      else
        append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Goal Amount", value: view.currency_display(goal_amount), card_stat_html: { class: "goalAmount" }
      end
    end
    append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Number of Donors", value: fundraiser.donation_count
  end

  def total_raised_label
    page_view.total_raised_label
  end

  def card_path
    view.peer_fundraising_home_page_url(fundraiser)
  end

  def raised_amount
    fundraiser.fundraising_total
  end

  def goal_amount
    fundraiser.fundraising_goal
  end

  def quantity_sold
    fundraiser.quantity_sold
  end

  def quantity_goal_type?
    fundraiser.goal_type == SharedSettingType::QUANTITY_SOLD_GOAL_TYPE
  end
end