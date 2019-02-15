$(document).ready ->

  $("#open_test_svg_modal_on_click").on 'click', ->
    $("#test_svg_modal").modal({keyboard: true, show: true})

  $("#test_svg_color_change_button").on 'click', ->
    elementId = $('.graph svg')[0].suspendRedraw(20)
    $($('[data-mercury-color]')[0]).attr('data-mercury-color', '#cccccc')
    MC.updateMercury
    $('.graph svg')[0].unsuspendRedraw(elementId)

  $("#test_svg_up_button").on 'click', ->
    if (MC.typeName == 'books')
      emptyNum = $('[data-mercury-percent-empty]').data('mercury-percent-empty') - 0.02;
      $('[data-mercury-percent-empty]').data('mercury-percent-empty', emptyNum)
      Thermometer.percentComplete = 1 - emptyNum;
      Thermometer.update();
    else
      $('#empty').attr('height', parseInt($('#empty').attr('height')) - 1)

  $("#test_svg_down_button").on 'click', ->
    if (MC.typeName == 'books')
      emptyNum = $('[data-mercury-percent-empty]').data('mercury-percent-empty') + 0.02;
      $('[data-mercury-percent-empty]').data('mercury-percent-empty', emptyNum)
      Thermometer.percentComplete = 1 - emptyNum;
      Thermometer.update();
    else
      $('#empty').attr('height', parseInt($('#empty').attr('height')) + 1)
