class EmailMessagesView
  INPUT_ATTRIBUTES =
      [
          # Message
          :id,
          :twitter_text,
          :facebook_text,
          :title,
          :send_at,
          :created_at,
          :updated_at,
          :send_now,
          :batch_id,
          :campaign_id,
          :message_type,
          :old_locale,
          :status,
          :external_id,
          :external_type,
          :messageable_id,
          :messageable_type,
          :email,
          :parent_id,
          :email,
          :constituent_lists
      ]

  OUTPUT_ATTRIBUTES =
    [
        :id,
        :title,
        :send_at,
        :created_at,
        :updated_at,
        :send_now,
        :campaign_id,
        :message_type,
        :status,
        :email,
        :constituent_lists
    ]

  attr_accessor *INPUT_ATTRIBUTES

  def initialize(message = nil)
    set_attributes(message) if message
  end

  def set_attributes(message)
    if message
      INPUT_ATTRIBUTES.each do |attribute|
        next unless message.send(attribute) rescue next # email throws NoMethodError exception, set after
        send("#{attribute}=", message.send(attribute))
      end

      if (messageable_id && messageable_type == EmailBroadcast.to_s)
        self.email = messageable_type.constantize.find_by_id(messageable_id)
      end
    end
  end

  def to_h
    # all attributes
    hash = {}
    INPUT_ATTRIBUTES.each do |attribute|
      hash[attribute] = send("#{attribute}") if attribute
    end
    # Rails.logger.debug "to_h output: " + hash.inspect
    hash
  end

  def filtered_hash
    # filtered attributes
    output = self.to_h.slice(*OUTPUT_ATTRIBUTES)

    # custom mapping for the builder
    # remap constituent lists to just an array of ids
    output[:constituent_lists] = output[:constituent_lists].map { |list| list.id } if output[:constituent_lists]
    output[:label] = output[:title]
    output[:campaign] = output[:campaign_id]
    # Rails.logger.debug "filtered_hash output: " + output.inspect
    
    output
  end
end
