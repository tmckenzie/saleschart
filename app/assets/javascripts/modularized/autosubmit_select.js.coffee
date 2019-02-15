$(document).on 'content-updated', ->
  $autoSubmitSelect = $('select.auto_submit')
  $autoSubmitSelect.one('change', (e) ->
    $(this).parents('form').first().submit()
  )
  $autoSubmitSelect.parents('form').find('input[type="submit"]').hide()
