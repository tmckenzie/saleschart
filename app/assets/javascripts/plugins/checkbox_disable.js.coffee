(($) =>
  enableContainer = ($el) ->
    containerToDisableSelector = $($el).data('elements-to-enable')
    $target = $(containerToDisableSelector)
    if $el.is(':checked')
      if $target.enableStyledCheckbox
        $target.enableStyledCheckbox()
      else
        $target.attr('disabled', false)
    else
      if $target.disableStyledCheckbox
        $(containerToDisableSelector).disableStyledCheckbox()
      else
        $target.attr('disabled', true)

  disableContainer = ($el) ->
    containerToDisableSelector = $($el).data('elements-to-disable')
    if $el.is(':checked')
      $(containerToDisableSelector).attr('disabled', true)
      if($(containerToDisableSelector).hasClass('datetimepicker'))
        $(containerToDisableSelector).val('')
    else
      $(containerToDisableSelector).attr('disabled', false)

  enableAlternate = ($el) ->
    alternateElements = $el.data('alternate-elements-for-disable')
    containerToDisableSelector = $el.data('elements-to-disable')

    if $(containerToDisableSelector+':checked').length > 0
      $(alternateElements).prop('checked', true)
      $(alternateElements).trigger('click')

  $.fn.checkboxEnable = ->
    $.each($(this), -> enableContainer($(this)))
    $(this).click -> enableContainer($(this))

  $.fn.checkboxDisable = ->
    $.each($(this), -> disableContainer($(this)))
    $(this).click -> disableContainer($(this))

  $.fn.checkboxDisabledAlternate = ->
    $(this).click -> enableAlternate($(this))

) jQuery

$(document).on 'content-updated', (e) ->
  $("input[data-elements-to-enable]").checkboxEnable()
  $("input[data-elements-to-disable]").checkboxDisable()
  $("input[data-alternate-elements-for-disable]").checkboxDisabledAlternate()

