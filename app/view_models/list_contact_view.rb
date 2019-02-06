# View Model for NposConstituentContact in a ConstituentList
class ListContactView
  include ActionView::Helpers::NumberHelper

  attr_reader :list_contact

  def initialize(list_contact)
    @list_contact = list_contact
  end

  def contact
    @contact ||= list_contact.npos_constituent_contact
  end

  def contact_type
    @contact_type ||= ConstituentContactType.find_by_class_name(contact.contactable_type)[:name]
  end

  def npos_constituent
    @npos_constituent ||= contact.npos_constituent
  end

  def phone_contact
    @phone_contact ||= (contact.phone_contact? ? contact : npos_constituent.phone_contact)
  end

  def phone
    number_to_phone(phone_contact.try(:contact_value), area_code: true)
  end

  def email_contact
    @email_contact ||= (contact.email_contact? ? contact : npos_constituent.email_contact)
  end

  def email
    email_contact.try(:contact_value)
  end

  def person_contact
    @person_contact ||= (contact.person_contact? ? contact : npos_constituent.person_contact)
  end

  def person_name
    person_contact.try(:contact_value).presence || '(no name)'
  end

  def source
    case list_contact.source
      when Subscription::SOURCE_CSV
        'List Upload'
      when Subscription::SOURCE_API
        'API'
      when Subscription::SOURCE_SMS
        'Keyword'
      when Subscription::SOURCE_PLEDGING_WIDGET
        'GiveLater'
      when Subscription::SOURCE_MESSAGING_WIDGET
        'Subscription Widget'
      when Subscription::SOURCE_SMS_OPT_IN
        'SMS Opt In'
      when Subscription::SOURCE_SMS_OPT_OUT
        'SMS Opt Out'
      when Subscription::SOURCE_NPO, Subscription::SOURCE_MC_ADMIN
        'Manually Added'
      else
        ''
    end
  end

  def subscription_status
    case list_contact.subscription_status
      when NposConstituent::SUBSCRIBED
        'Subscribed'
      when NposConstituent::UNSUBSCRIBED
        'Unsubscribed'
      when NposConstituent::IMPORTED
        'Newly Imported'
      when NposConstituent::INVITED
        'Invited'
      when NposConstituent::PENDING_INVITE
        "Invitation Pending"
      when NposConstituent::PENDING_WELCOME
        "Welcome Pending"
      when NposConstituent::OPT_OUT
        "Opted Out"
      else
        ''
    end
  end

  def subscription_date
    date = contact.phone_contact? ?
             npos_constituent.last_subscription_activity(NpoSubscriptionActivity::SUBSCRIBE).try(:created_at)
             : list_contact.created_at
    display_date_for(date)
  end

  def display_date_for(date)
    date.present? ? date.strftime("%m/%d/%y") : "n/a"
  end

  def can_unsubscribe?
    contact.phone_contact? && list_contact.subscribed?
  end

  def unsubscribe_contact_warning_text
    contact.phone_contact? ?
      'This action will unsubscribe phone from all of your lists.  Would you still like to continue ?'
      : 'This action will unsubscribe contact from the list.  Would you still like to continue ?'
  end

  def remove_contact_warning_text
    # contact_value = contact.phone_contact? ? "Phone Number [#{phone}]" : "Email Address [#{email}]"
    "#{person_name} will be removed from the list.  Would you still like to continue ?"
  end
end