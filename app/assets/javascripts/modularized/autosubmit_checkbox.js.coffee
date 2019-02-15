$(document).on 'content-updated', ->
  $autoSubmitCheckbox = $('input[type=checkbox].auto_submit')
  $autoSubmitCheckbox.one('change', (e) ->
    $(this).parents('form').first().submit()
  )
  $autoSubmitCheckbox.parents('form').find('input[type="submit"]').hide()
