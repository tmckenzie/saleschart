$(function() {
  return $('[data-modernizr]').each(function() {
    var $el, $toggler;
    $el = $(this);
    $el.toggleClass('mc-modernizr-nope', !Modernizr[$el.data('modernizr')]);
    if ($el.data('modernizr-toggle') != null) {
      $toggler = $('<a class="toggle" href="#"><span class="fa fa-th-large right-large"></span></a>').click(function(e) {
        e.preventDefault();
        return $el.toggleClass('mc-modernizr-nope');
      });
      return $el.prepend($toggler);
    }
  });
});