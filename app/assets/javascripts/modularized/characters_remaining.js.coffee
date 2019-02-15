(($) =>
  $.fn.displayRemainingCharactersCount = ->
    $(this).each ->
      $el = $(this)
      max_length = $el.data('maxlength')
      $display = $('<small class="display-character-count pull-right"></small>')

      lengthOfValueFor = ($el) -> $el.val().replace(/(\n|\r\n)/g,'xx').length
      update_display = ->
        current_length = lengthOfValueFor($el)
        $display.text("#{max_length - current_length} characters left").toggleClass('text-danger', current_length > max_length)

      $el.keyup(update_display)
      $el.after($display)
      update_display()
) jQuery
