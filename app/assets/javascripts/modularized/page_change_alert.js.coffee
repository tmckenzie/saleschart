$ ->
  input_values = {}
  trigger_alert_message = false
  $(document).ready ->
    return $("[data-page-alert=\"true\"]").size() == 0
    $("[data-page-alert=\"true\"]").each ->
      $(this).find(":input").each ->
        if $(this).attr('id')
          input_values[$(this).attr('id')] = $(this).val()
          return
    input_values

    $("[data-page-alert=\"true\"]").change ->
      trigger_alert_message = false
      $(this).find(":input").each ->
        if $(this).attr('id')
          if( input_values[$(this).attr('id')] != $(this).val() )
            trigger_alert_message = true
          return

    $("[data-page-alert=\"true\"]").submit ->
      trigger_alert_message = false
      true

    $(window).on 'beforeunload', ->
      if trigger_alert_message
        "You have not saved the changes!"
      return

    $(window).data('beforeunload', window.onbeforeunload);

    $("a").hover (->
      window.onbeforeunload = null
      return
    ), ->
      window.onbeforeunload = $(window).data('beforeunload')
