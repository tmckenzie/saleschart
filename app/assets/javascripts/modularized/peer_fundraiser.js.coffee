$(->
  $(document).ready ->
    # Execute this only if custom field template forms are present
    $('#cta').on 'blur', ->
      $('#signup_cta').text($(this).val())

    $('.copy_to_clipboard_alert').on 'click', (e)->
      copyToClipboard($('.clipboard_text').text())

    copyToClipboardAlert = (text) ->
      window.prompt "Copy to clipboard: Ctrl+C, Enter", text
      return

    $("#fundraising_form_submit_btn").on('click', ->
      ajax_save_button_styler(this.closest("form").attr('action'), $(this))
      false
    )

    $("#fundraising_form_save_btn").on('click', ->
      ajax_save_button_styler($(this).attr('href'), $(this))
      false
    )

    $("#signup_form_submit_btn").on('click', ->
       ajax_save_button_styler(this.closest("form").attr('action'), $(this))
       false
    )

    $("#signup_form_save_btn").on('click', ->
      ajax_save_button_styler($(this).attr('href'), $(this))
      false
    )

)
