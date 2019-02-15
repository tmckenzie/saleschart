(($) ->
  $(->
    $('select#campaign_id').change ->
      window.location.href = "/messages/?campaign_id=#{$(this).val()}"

    $('input#message_send_now').click ->
      if($(this).is(":checked"))
        $('#schedule-or-send-button').val('Send a Message')
      else
        $('#schedule-or-send-button').val('Schedule Message')

    $('input#select_all_lists_for_messages_check_box').click ->
      $("[id^=constituent_list_ids]").prop('checked', $(this).prop('checked'))

    $('#new-campaign-button').click ->
      $("select#activity_campaigns_list").prop('selectedIndex', 0)

    $(document).on 'content-updated', ->
      $modal = $('[data-modal=immediate]:first')
      if $modal.length > 0
        $.blockUI
          message: $modal
          css:
            border: 0
            'background-color': 'transparent'

  )
)(jQuery)
