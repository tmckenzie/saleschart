$(function() {
  var checked, stopAutomaticPolling;
  checked = 'checked';

  $('.backgrounds').click(function(jqe) {
    return $('#graph_setting_display_which_background_id_3').prop('checked', checked);
  });

  $('#graph_setting_background_color').change(function(jqe) {
    return $('#graph_setting_display_which_background_id_1').prop('checked', checked);
  });

  $('#graph_setting_bg').click(function(jqe) {
    return $('#graph_setting_display_which_background_id_2').prop('checked', checked);
  });

  $('[data-click-value]').click(function(jqe) {
    var $el, $target;
    jqe.preventDefault();
    $el = $(this);
    $target = $($el.data('click-target'));
    $target.css({
      background: 'transparent',
      color: "#000"
    });
    return $target.val($el.data('click-value')).closest('form').trigger('change');
  });

  (stopAutomaticPolling = function() {
    if (typeof iframeMC !== "undefined" && iframeMC !== null) {
      return iframeMC.stop();
    } else {
      return setTimeout(stopAutomaticPolling, 500);
    }
  })();

  return $('#fundraising-thermometer form').on('ajax:complete', function() {
    if (typeof iframeMC !== "undefined" && iframeMC !== null) {
      return iframeMC.poll();
    }
  });

});