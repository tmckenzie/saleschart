$(document).on 'content-updated', ->
  createOrUpdateImage = (target_id, url) ->
    $container = $("[data-id=#{target_id}]")
    $img = $container.find("img")
    if $img.length <= 0
      width = $container.data('width')
      css_class = $container.data('class')
      $img = $($('<img>'))
      $img.attr('width', width)
      $img.attr('class', css_class)
      $container.append($img)
    $img.attr('src', url)
    $img.show()
    true
  fileuploadEvents =
    fileuploadadd: (e, data) ->
      target_id = $(e.target).data('target-preview-id')
      $("[data-id=#{target_id}] img").hide()
      $("[data-id=#{target_id}]").html('<div data-processing><em>processing...</em></div>')
    fileuploaddone: (e, data) ->
      $file_field = $(e.target)
      target_id = $file_field.data('target-preview-id')
      $("[data-id=#{target_id}] [data-processing]").remove()
      createOrUpdateImage(target_id, data.result.image)
      $(document).trigger('mc:file-uploaded', {$file_field: $file_field, url: data.result.image, img_type: data.result.img_type})
  $('[data-fileupload]').each ->
    $file_field = $(@)
    for event, handler of fileuploadEvents
      $file_field.off(event, handler).on(event, handler)
