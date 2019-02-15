$(function () {
  $('form[data-mc-auto-submit-remote]').on('change', function (jqe) {
    $(this).attr('data-unsaved-flag', 'true');
    $(this).trigger('submit.rails');
  });
});