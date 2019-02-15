function stripCommasFromDonationAmount() {
  var totalAmt = $('.donation_amount').val();
  if (totalAmt != undefined) {
    $('.donation_amount').val(totalAmt.replace(/,/g, ''));
  }
}

$.validator.addMethod('positiveNumber',
 function (value) {
     return /^(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d{1,2})?$/.test(value);
 }, 'Enter a valid amount');
