class SubscriptionHistory::AdminView

  INPUT_ATTRIBUTES =
      [
          :activity,
          :activity_dt,
          :activity_source,
          :npo_name,
          :keyword,
          :shortcode,
          :mo_content,
          :terms_url
      ]

  DISPLAY_ATTRIBUTES =
      [
          :event,
          :initiated_at,
          :initiate_source,
          :subscribed_at,
          :subscribe_source,
          :unsubscribed_at,
          :unsubscribe_source,
          :npo_confirmed_terms_url
      ]

  attr_accessor *INPUT_ATTRIBUTES
  attr_reader *DISPLAY_ATTRIBUTES

  def initialize(attributes = {})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    if attributes
      INPUT_ATTRIBUTES.each do |attribute|
        next unless attributes[attribute]
        send("#{attribute}=", attributes[attribute])
      end
      set_display_attributes
    end
  end

  def set_display_attributes
    case activity
      when NpoSubscriptionActivity::INVITE
        @event = "Eligible"
        @initiated_at = format_datetime_for_display(activity_dt)
        @initiate_source = source_text_for_initiated(activity_source)
      when NpoSubscriptionActivity::SUBSCRIBE
        @event = "Subscribed"
        @subscribed_at = format_datetime_for_display(activity_dt)
        @subscribe_source = source_text_for_subscribed(activity_source)
        @npo_confirmed_terms_url = terms_url if activity_source == NpoSubscriptionActivity::SOURCE_NPO
      when NpoSubscriptionActivity::UNSUBSCRIBE
        @event = "Unsubscribed"
        @unsubscribed_at = format_datetime_for_display(activity_dt)
        @unsubscribe_source = source_text_for_unsubscribed(activity_source)
    end
  end

  def source_text_for_initiated(source)
    case source
      when NpoSubscriptionActivity::SOURCE_PLEDGING_WIDGET
        "Pledging Widget"
      when NpoSubscriptionActivity::SOURCE_MESSAGING_WIDGET
        "Subscription Widget"
      when NpoSubscriptionActivity::SOURCE_NPO
        "Client Invitation Message"
      else
        ""
    end
  end

  def source_text_for_subscribed(source)
    case source
      when NpoSubscriptionActivity::SOURCE_PLEDGING_WIDGET
        "Pledging Widget + Handset Confirmation"
      when NpoSubscriptionActivity::SOURCE_MESSAGING_WIDGET
        "Subscription Widget + Handset Confirmation"
      when NpoSubscriptionActivity::SOURCE_SMS
        "Keyword"
      when NpoSubscriptionActivity::SOURCE_SMS_OPT_IN
        "Invitation Message + Handset Confirmation"
      when NpoSubscriptionActivity::SOURCE_NPO
        "Client Certified"
      else
        ""
    end
  end

  def source_text_for_unsubscribed(source)
    case source
      when NpoSubscriptionActivity::SOURCE_SMS
        "SMS STOP Reply"
      when NpoSubscriptionActivity::SOURCE_SMS_OPT_OUT
        "Invitation Message + SMS STOP Reply"
      when NpoSubscriptionActivity::SOURCE_NPO
        "Client Admin"
      when NpoSubscriptionActivity::SOURCE_MC_ADMIN
        "MobileCause Admin"
      else
        ""
    end
  end

  def format_datetime_for_display(datetime)
    DateTimeFormatter.new(datetime).display_default_with_meridian
  end

  def format_text_for_display(text)
    text.present? ? text : "n/a"
  end

  def ==(other)
    return false if other.nil? || !other.is_a?(SubscriptionHistory::AdminView)
    INPUT_ATTRIBUTES.each do |attribute|
      return false if send(attribute) != other.send(attribute)
    end
    return true
  end

  comma do |history|
    event
    initiated_at
    initiate_source
    subscribed_at
    subscribe_source
    unsubscribed_at
    unsubscribe_source
    npo_name
    mo_content "Message Received"
    npo_confirmed_terms_url "Client Confirmed Terms"
  end
end