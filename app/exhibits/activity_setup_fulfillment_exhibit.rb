class ActivitySetupFulfillmentExhibit < Exhibit
  delegate :activity_config, to: :model

  def initialize(model, context)
    super
    @call_center_renderer = model.npo.has_feature?(Feature::CALL_CENTER) ? CallCenterRenderer.new : Widgets::NullContainer.new
  end

  def html_id
    "fulfillment"
  end

  def heading
    "Fulfillment"
  end

  def to_partial_path
    "activities/mobile_pledging/setup_fulfillment"
  end

  def reminders
    [RemindersConfiguration.day2, RemindersConfiguration.day5, RemindersConfiguration.day9]
  end

  def call_center_fields
    @call_center_renderer
  end

  class CallCenterRenderer
    def to_partial_path; "activities/mobile_pledging/setup_fulfillment_call_center"; end
  end
end