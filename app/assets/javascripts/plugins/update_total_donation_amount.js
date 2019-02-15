(function ($) {
  $.fn.updateTotalDonationAmount = function () {
    var $inputs = $(this);

    $inputs.focus(function () {

      $(this).blur(function () {
        if (this.value === "") {
          $("#total-donation-amount").text("$" + this.defaultValue);
        }
        else {
          $("#total-donation-amount").text("$" + this.value);
        }

      });
    });
    return $inputs;
  };

})(jQuery);