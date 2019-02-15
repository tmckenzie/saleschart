(function($, window) {
  // This adds 'placeholder' to the items listed in the jQuery .support object.
  $.support.placeholder = false;
  var test = document.createElement('input');
  if ('placeholder' in test) $.support.placeholder = true;

  // This adds placeholder support to browsers that wouldn't otherwise support it.
  function placeholderShiv() {
    if (!$.support.placeholder) {
      var active = document.activeElement;
      $(':text').focus(
          function () {
            if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
              $(this).val('').removeClass('hasPlaceholder');
            }
          }).blur(function () {
            if ($(this).attr('placeholder') != '' && $(this).attr('placeholder') != undefined && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
              $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
            } else {
              $(this).removeClass('hasPlaceholder');
            }
          });
      $(':text').blur();
      $(active).focus();
      $('form:eq(0)').submit(function () {
        $(':text.hasPlaceholder').val('');
      });
    }
  }
  window.placeholderShiv = placeholderShiv;
  $(placeholderShiv);
})(jQuery, this);
