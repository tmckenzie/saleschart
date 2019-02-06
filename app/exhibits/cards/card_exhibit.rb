class Cards::CardExhibit < Blocks.builder_class
  # card blocks
  CARD_BLOCK = :card
  CARD_HEADER_BLOCK = :card_header
  CARD_BODY_BLOCK = :card_body
  CARD_FOOTER_BLOCK = :card_footer
  CARD_TITLE_BLOCK = :card_title
  CARD_IMAGE_BLOCK = :card_image
  CARD_DETAILS_BLOCK = :card_details
  CARD_STATS_BLOCK = :card_stats
  CARD_STAT_BLOCK = :card_stat
  CARD_ACTION_BLOCK = :card_action
  CARD_STATUS_BLOCK = :card_status
  CARD_PROGRESS_BLOCK = :card_progress

  # card display styles
  CARD_LIST_STYLE = :card_list_style
  CARD_GRID_STYLE = :card_grid_style

  attr_accessor :model, :parent_builder

  delegate :view, to: :parent_builder

  def initialize(parent_builder, model)
    self.model = model
    self.parent_builder = parent_builder
    super view
  end

  def card_path
    raise NotImplementedError
  end
end