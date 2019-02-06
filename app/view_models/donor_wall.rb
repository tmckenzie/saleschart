class DonorWall

  INPUT_ATTRIBUTES =
      [
          :fundraising_goal,
          :donor_list,
          :total_donors,
          :total_raised
      ]

  attr_accessor *INPUT_ATTRIBUTES

  def initialize(attributes = {})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    if attributes
      INPUT_ATTRIBUTES.each do |attribute|
        next unless attributes[attribute]
        send("#{attribute}=", attributes[attribute])
      end
    end
    @fundraising_goal = 0 if @fundraising_goal.blank?
    @total_raised = 0 if @total_raised.blank?
  end

  def total_remaining
    [fundraising_goal - total_raised, 0].max
  end

  def total_exceeded
    [total_raised - fundraising_goal, 0].max
  end

  def percent_empty
    return 0 if  fundraising_goal == 0
    [total_remaining / fundraising_goal, 1].min
  end

end