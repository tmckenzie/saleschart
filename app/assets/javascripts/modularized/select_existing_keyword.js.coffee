$(document).on('content-updated', ->
  populateKeywordExtrasTemplate = ($extras, $option) ->
    $extras.find('[data-class=keyword]').text($option.data('keyword'))
    $extras.find('[data-class=shortcode]').text($option.data('shortcode'))
    $extras.find('[data-class=campaign-name]').text($option.data('campaign-name'))

  $('[data-class=existing-keyword]').each ->
    $select = $(@)
    extras_id = $select.data('extras-target')
    text_field_id = $select.data('text-field-target')
    $select.change (e) ->
      $option = $('option:selected', $select)
      keyword_string = $option.data('keyword')
      $text_field = $("[data-id=#{text_field_id}]")
      $extras = $("[data-id=#{extras_id}]")
      saved = $text_field.data('saved-value')
      if $select.val() is ''
        action = 'hide'
        $text_field.val(saved).prop("disabled", false)
      else
        action = 'show'
        if saved is undefined
          $text_field.data('saved-value', $text_field.val())
        $text_field.val(keyword_string).attr('disabled', true)
        populateKeywordExtrasTemplate($extras, $option)

      $extras.collapse(action)
)