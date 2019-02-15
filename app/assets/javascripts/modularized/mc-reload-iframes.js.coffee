$(->

  #see http://stackoverflow.com/questions/86428/whats-the-best-way-to-reload-an-iframe-using-javascript
  reload_iframes = (selector) ->
    $(selector).each ->
      el = this
      if(el.location )
        el.location.reload(true)
      else if (el.contentWindow.location )
        el.contentWindow.location.reload(true)
      else if (el.src)
        el.src = el.src

  handler = (jqe, data) ->
    selector = $(this).closest('form').data('mc-trigger-reload')
    reload_iframes(selector)
  $('[data-mc-trigger-reload] [data-fileupload]').on('fileuploaddone', handler )
  $('[data-mc-trigger-reload]').on('ajax:complete', handler )
)