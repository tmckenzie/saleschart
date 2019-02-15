(($) =>
  $.fn.dollarPrefix = ->
    if $(this).is('input[type="text"]')

      $input = $(this)

      addDollarSign($input)

      $input.blur ->
        addDollarSign($(this))

      $input.parents('form').one('submit', ->
        strippedValue = $input.val().match(/[^$]+/)
        $input.val(strippedValue)
      )
      
  addDollarSign = ($input) ->
    unless $input.val().match(/\$/)
      newValue = '$' + $input.val()
      $input.val(newValue)
) jQuery
