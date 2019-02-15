$(->
  return unless $deferred = $('[data-deferred]')

  $deferred.each (i, el) ->
    setTimeout(
      ->
        $el = $(el)
        deferred_path = $el.data('deferred')
        $.get(deferred_path).success (data)->
          value = data[deferred_path]
          $el.before(value).remove()
      , 2000
    )
)
