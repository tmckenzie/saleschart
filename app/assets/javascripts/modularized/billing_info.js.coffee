$(document).on('content-updated', ->
  $all_amounts = $('input[data-plan-amount]')
  $all_frequencies = $('input[data-frequency]')
  $custom = $('input[data-custom-plan-amount]')

  update_billing_frequency = (e) ->
    $amount = $('input[data-plan-amount]:checked')
#    $amount = $('input[data-plan-amount]:first') unless $amount.length > 0
    $freq = $('input[data-frequency]:checked')
#    $freq = $('input[data-frequency]:first') unless $freq.length > 0

    hide_frequency = !!$amount.data('hide-frequency')
    if hide_frequency
      $('.billing_freq').hide()
      multiplier = 1
    else
      $('.billing_freq').show()
      multiplier = parseInt($freq.data('plan-amount-multiplier'))

    if !!$amount.data('is-custom')
      $custom.removeAttr('disabled')
      plan_amount = parseInt($custom.val())
    else
      $custom.attr('disabled', 'disabled')
      plan_amount = parseInt($amount.data('plan-amount'))

    unless hide_frequency
      $all_frequencies.each(->
        frequency = $(@).data('frequency')
        local_multiplier = parseInt($(@).data('plan-amount-multiplier'))
        $label = $("label[data-frequency=#{frequency}]")
        local_amount = plan_amount*local_multiplier
        value = if isNaN(local_amount) then '' else "$#{local_amount}"
        $label.html(value)
      )

    total = multiplier * plan_amount

    $('.total_due').val(if isNaN(total) then '' else '$'+total)

  $all_amounts.on 'click', update_billing_frequency
  $all_frequencies.on 'click', update_billing_frequency
  $custom.on 'keyup', update_billing_frequency

  update_billing_frequency()
  window.update_billing_frequency = update_billing_frequency
)
