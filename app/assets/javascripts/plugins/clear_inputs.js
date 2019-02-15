(function ($) {
  $.fn.clearInputs = function () {
    var $inputs = $(this);

    $inputs.focus(function () {
      if (this.defaultValue === this.value) {
        this.value = "";
      }
      $(this).blur(function () {
        if (this.value === "") {
          this.value = this.defaultValue;
        }
      });
    });
    return $inputs;
  };

  $.fn.swapPasswordInputs = function () {
//    NEVER USE THIS ON AN EDIT PAGE AS IT WILL REVEAL PASSWORDS!!!!
    var $inputs = $(this);
    $inputs.attr('type','text');
    $inputs.focus(function() {
      $(this).attr('type','password')
    })
    $inputs.blur(function () {
      if (this.value == "") {
        $(this).attr('type','text');
      }
    })
    return $inputs;
  };
}(jQuery));