$(->
  $(document).ready ->
    $(document).on('content-updated', ->
      if($("[data-preview-tab-container]").length && !$("div.alert.alert-danger").length)
        $("[data-preview-tab-container]").each ->
          reloadActivePreviewIFrame($(this))
    )

    reloadActivePreviewIFrame=($iFrameElem) ->
      tabId = $iFrameElem.attr('data-preview-tab-container')
      # Reload the active tab (or no tab) preview iframe.
      if(tabId == '' || $('#'+tabId).hasClass('active'))
        if $iFrameElem.is(':visible')
          $iFrameElem.get(0).contentDocument.location.reload(true);
        if tabId == ''
          formId = 'preview_before_save_form'
        else
          formId = tabId + '_form'

  window.ajax_save_button_styler= (url, btn) ->
    original = btn.text()
    if ( btn.attr('disabled') != undefined )
      return


    $.ajax
      url: url
      type: "PUT"
      dataType: "script"
      data: {}
      beforeSend: ->
        btn.attr('disabled', 'disabled')
        btn.text "Saving"
        return

      complete: ->
        btn.closest("form").attr('data-unsaved-flag', 'false');
        btn.text("Saved")
        existing_style = btn.attr('style')
        new_style = 'font-style:italic; font-weight:bold;'
        if typeof existing_style is 'undefined'
          existing_style = ''
        btn.attr('style', new_style + existing_style)
        setTimeout( ->
          btn.removeAttr('disabled')
          btn.attr('style', existing_style)
          btn.text(original)
          2000)
        return
)
