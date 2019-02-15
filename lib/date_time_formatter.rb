class DateTimeFormatter
  def initialize(datetime = Time.zone.now)
    @datetime = datetime
  end

  def schedule_during_next_business_hours
    scheduled_time = @datetime.beginning_of_day + 11.hours
    scheduled_time = scheduled_time + 1.day if scheduled_time < Time.zone.now
    scheduled_time
  end

  def during_business_hours?
    current_hour = @datetime.hour
    current_hour >= 8 && current_hour < 20
  end

  def display_long_with_meridian
    display(@datetime, :long_with_meridian)
  end

  def display_default_with_meridian
    display(@datetime, :default_with_meridian)
  end

  def display_default
    display(@datetime, :default)
  end

  def display_date_only
    display(@datetime, :default, Date)
  end

  def format_string_to_default_with_meridian
    if @datetime.present? && @datetime.class == String
      reformatted_time_string = DateTime.strptime(@datetime, Time::DATE_FORMATS[:default_with_meridian]).to_s(:db)
      Time.zone.parse(reformatted_time_string).utc.to_datetime
    elsif @datetime.present? && (@datetime.class == DateTime || @datetime.is_a?(Time))
      @datetime
    else
      nil
    end
  end

  def format_string_to_default
    if @datetime.present? && @datetime.class == String
      reformatted_time_string = DateTime.strptime(@datetime, Time::DATE_FORMATS[:default]).to_s(:db)
      Time.zone.parse(reformatted_time_string).utc.to_datetime
    elsif @datetime.present? && (@datetime.class == DateTime || @datetime.is_a?(Time))
      @datetime
    else
      nil
    end
  end

  private

  def display(datetime, format, time_or_date_class = Time)
    # Check if the datetime is present and is a DateTime, Time, or ActiveSupport::TimeWithZone object so that we know how to format it.
    if datetime.present? && (datetime.class == DateTime || datetime.is_a?(Time))
      # datetime.strftime(time_or_date_class::DATE_FORMATS[format])
    else
      nil
    end
  end
end