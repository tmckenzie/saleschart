//= require raphael
//= require colorwheel

$(function () {
  $pickers = $('[data-mc-picker=colorwheel]');
  function styleInput($el, clr) {
    $el.css({
      background: clr,
      color: clr !== 'transparent' && Raphael.rgb2hsb(clr).b < .5 ? "#fff" : "#000"
    });
  }
  $pickers.each(function(){
    var $el = $(this), clr = $el.val();
    styleInput($el, clr);
  });
  $pickers.on('focus', function (jqe) {
    var $el = $(this),
        coords = $el.offset(),
        left = (coords.left + $el.width() + 28),
        topCoordinate = (coords.top + parseInt($el.height()/2) - 60),
        cw = Raphael.colorwheel(left, topCoordinate, 120, $el.val());
    $(cw.raphael.canvas).attr('class', 'mc-picker');
    cw.onchange = function (clr) {
      $el.val(clr.replace(/^#(.)\1(.)\2(.)\3$/, "#$1$2$3")).trigger('change');
      cw.color(clr);
    };
    $el.data('mc-picker-element', cw);
  }).on('change', function (jqe) {
    var $el = $(this), clr = $el.val();
    $el.data('mc-picker-element').color(clr);
    styleInput($el, clr);
  }).on('blur', function (jqe) {
    var $el = $(this), picker = $el.data('mc-picker-element');
    if (picker)
      picker.remove();
    $el.removeData('mc-picker-element');
  });
});

$(document).on('content-updated', function () {
  $pickers = $('[data-mc-picker=newcolorwheel]');
  $pickers.each(function(){
    var $el = $(this), clr = $el.val();
    $el.css({"background-color": clr, "color": clr});
  });
  $pickers.off('focus').on('focus', function (jqe) {
    $el = $(this);
    $target = $el.data("targetId"),
    coords = $el.offset(),
    left = (coords.left + $el.width() + 28),
    topCoordinate = (coords.top + parseInt($el.height()/2) - 60),
    cw = Raphael.colorwheel(left, topCoordinate, 120, $el.val());
    $(cw.raphael.canvas).attr('class', 'mc-picker').css("z-index", $(".modal").css("z-index") + 1);
    cw.onchange = function (clr) {
      $el.css({"background-color": clr, "color": clr});
      $el.val(clr);
      cw.color(clr);
    };
    $el.data('mc-picker-element', cw);
  }).off('blur').on('blur', function (jqe) {
    var $el = $(this),
    picker = $el.data('mc-picker-element'),
    $target = $el.data("targetId");

    if (picker)
      picker.remove();

    $el.removeData('mc-picker-element');

    if($("#"+$target).val() != $el.val()){
      $("#"+$target).val($el.val());
      $('[data-color-id=' + $el.data("targetId") + ']').hide();
      $el.trigger('change');
    }
  });
});

$(document).on('content-updated', function () {
  $colorText = $('.input-interior-colorwheel-text');
  $colorText.on('change', function(jqe){
    var color = $(this).val();

    if(color.match(/^#([0-9a-f]{3}){1,2}$/i) != null){
      $('[data-target-id=' + this.id + ']').css({"background-color": color, "color": color});
      $('[data-target-id=' + this.id + ']').val(color);
      $('[data-target-id=' + this.id + ']').trigger('change');
      $('[data-color-id=' + this.id + ']').hide();
    } else {
      $('[data-color-id=' + this.id + ']').show();
    }
    return false;
  });
});
