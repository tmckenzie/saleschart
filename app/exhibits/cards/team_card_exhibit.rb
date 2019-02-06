class Cards::TeamCardExhibit < Cards::CardExhibit
  alias_method :team, :model

  RAISED_STAT = :raised_stat
  GOAL_STAT = :goal_stat

  def render_component(options={}, &block)
    options = options.with_indifferent_access
    render options.merge(partial: "shared/components/card") do |builder, runtime_context|
      yield builder, runtime_context if block_given?

      # setup overlay link
      prepend CARD_BLOCK do
        view.link_to card_path, class: "card__overlay", target: "_blank" do
          content_tag :span, "Go to #{team.display_name}", class: "sr-only"
        end
      end

      # Setup card image
      define CARD_IMAGE_BLOCK, image_html: { class: "img-#{profile_picture_type}" } if profile_picture_type
      if team.team_logo.present?
        define CARD_IMAGE_BLOCK, image: team.team_logo
      end

      # Setup card title
      define CARD_TITLE_BLOCK, title: team.display_name

      # Setup card action
      define CARD_ACTION_BLOCK, with: :link_to, label: "View", path: card_path, link_html: { class: "btn", target: "_blank" }

      total = if quantity_goal_type?
        quantity_sold
      else
        view.currency_display(raised_amount)
      end
      define RAISED_STAT, with: CARD_STAT_BLOCK, label: team.goal_measurement_label, value: total, card_stat_html: { class: "amountRaised" }

      goal = if quantity_goal_type?
        goal_amount
      else
        view.currency_display(goal_amount)
      end
      define GOAL_STAT, with: CARD_STAT_BLOCK, label: "Goal", value: goal, card_stat_html: { class: "goalAmount" }

      if runtime_context[:card_type] == :list
        setup_list_card(runtime_context)
      elsif runtime_context[:card_style] == "descriptive"
        setup_descriptive_card(runtime_context)
      else
        setup_basic_card(runtime_context)
      end
    end
  end

  private

  def profile_picture_type
    parent_builder.page_view.profile_picture_type if parent_builder.respond_to?(:page_view)
  end

  def setup_list_card(runtime_context)
    define CARD_BLOCK, with: CARD_LIST_STYLE, card_html: { class: "card__teams--list--basic updateProgressBar", data: { team: team.display_name } }
    define CARD_DETAILS_BLOCK, with: :card_text_to_give, keyword: team.team_captain_peer_fundraiser.personal_keyword, shortcode: team.team_captain_peer_fundraiser.shortcode_string
    append CARD_STATS_BLOCK, with: RAISED_STAT
    if team.campaigns_keyword.has_fundraising_goal?
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Donors", value: team.collected_fundraising_donations.count
      append CARD_STATS_BLOCK, with: GOAL_STAT
    else
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "", value: ""
      append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Donors", value: team.collected_fundraising_donations.count
      define CARD_STATS_BLOCK, wrapper_html: {style: 'margin-top: 10px'}
      skip CARD_PROGRESS_BLOCK
    end
  end

  def setup_descriptive_card(runtime_context)
    define CARD_BLOCK, card_html: { class: "card__teams--#{runtime_context[:card_type]}--modern updateProgressBar" }
    define CARD_DETAILS_BLOCK do
      view.content_tag :p, view.strip_tags(team.call_to_action).gsub("&nbsp;", "")
    end
    append CARD_STATS_BLOCK, with: RAISED_STAT
    if team.campaigns_keyword.has_fundraising_goal?
      append CARD_STATS_BLOCK, with: GOAL_STAT
    else
      skip CARD_PROGRESS_BLOCK
    end
  end

  def setup_basic_card(runtime_context)
    define CARD_BLOCK, card_html: { class: "card__teams--#{runtime_context[:card_type]}--basic updateProgressBar", data: { team: team.display_name } }
    define CARD_DETAILS_BLOCK, with: :card_text_to_give, keyword: team.team_captain_peer_fundraiser.personal_keyword, shortcode: team.team_captain_peer_fundraiser.shortcode_string
    skip CARD_PROGRESS_BLOCK
    append CARD_STATS_BLOCK, with: RAISED_STAT
    if team.campaigns_keyword.has_fundraising_goal?
      append CARD_STATS_BLOCK, with: GOAL_STAT
    end
    append CARD_STATS_BLOCK, with: CARD_STAT_BLOCK, label: "Number of Members", value: team.team_members_total
  end

  def card_path
    view.volunteer_fundraiser_teams_link_url(team.campaigns_keyword.shortcode.url_node.to_s, team.campaigns_keyword.keyword_string, team.name)
  end

  def raised_amount
    team.display_team_fundraising_total
  end

  def goal_amount
    team.display_team_fundraising_goal
  end

  def quantity_sold
    team.quantity_sold
  end

  def quantity_goal_type?
    team.goal_type == SharedSettingType::QUANTITY_SOLD_GOAL_TYPE
  end
end