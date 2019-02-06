class Sharing::TextShareTemplate < Sharing::AbstractSharingTemplate
  attr_accessor :activity

  def initialize(activity)
    self.activity = activity
  end

  def keyword
    activity.keyword_string
  end

  def keyword_for(fundraiser)
    if fundraiser.present? && fundraiser.parent_id != nil
      fundraiser.personal_keyword
    else
      activity.keyword_string
    end
  end

  def shortcode
    activity.shortcode_string
  end
end