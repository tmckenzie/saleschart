class DonationView
  include FoxDateTimeHelper
  include ActionView::Helpers::NumberHelper

  INPUT_ATTRIBUTES =
      [
          :id,
          :amount,
          :status,
          :phone,
          :first_name,
          :last_name,
          :email,
          :address,
          :city,
          :state,
          :zip,
          :keyword,
          :shortcode,
          :campaign,
          :npo_name,
          :npo_id,
          :created_at,
          :donor_registration
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
  end

  def amount_for_display
    amount.nil? ? "$0.00" : "$#{Money.from_bigdecimal(amount)}"
  end

  def donor_phone
    number_to_phone(phone, area_code: true)
  end

  def donor_name
    [first_name, last_name].compact.join ' '
  end

  def keyword_description
    "#{keyword} on #{shortcode} for #{campaign}"
  end

  def donated_at
    format_friendly_time(created_at)
  end

  def donor_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  def donor_registration_details
    self.donor_registration.present? ? self.donor_registration.registration_id : ''
  end
end