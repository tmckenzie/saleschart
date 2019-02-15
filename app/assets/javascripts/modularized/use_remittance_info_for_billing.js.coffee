window.FillBilling = (f, type) ->
  if f.billingtoo.checked is true
    $("\##{type}_billing_contact_first_name").val $("\##{type}_remittance_contact_first_name").val()
    $("\##{type}_billing_contact_last_name").val $("\##{type}_remittance_contact_last_name").val()
    $("\##{type}_billing_contact_email").val $("\##{type}_remittance_contact_email").val()
    $("\##{type}_billing_contact_address").val $("\##{type}_remittance_contact_address").val()
    $("\##{type}_billing_contact_city").val $("\##{type}_remittance_contact_city").val()
    $("\##{type}_billing_contact_state").val $("\##{type}_remittance_contact_state").val()
    $("\##{type}_billing_contact_zip").val $("\##{type}_remittance_contact_zip").val()
    $("\##{type}_billing_contact_phone_number").val $("\##{type}_remittance_contact_phone_number").val()