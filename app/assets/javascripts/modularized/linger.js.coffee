$(document).on 'content-updated', ->
  $('[data-linger]').each ->
    $el = $(@)
    delay = $el.data('linger') or 1500
    $el.delay(delay).fadeOut();