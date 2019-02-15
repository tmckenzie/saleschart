// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require ./plugins/clear_inputs
//= require ./plugins/jquery_inline_date_formatter
//= require ./plugins/dollar_prefix
//= require ./plugins/jquery.validate.min
//= require ./plugins/jquery.mask.min
//= require ./plugins/jquery.payment
//= require ./plugins/additional-methods.min
//= require ./plugins/bootbox.min
//= require ./plugins/payment_form
//= require ./plugins/update_total_donation_amount

jQuery(document).ready(function () {
  jQuery('input.clear_me').clearInputs();
  jQuery('form.clear_inputs input[type="text"], form.clear_inputs input[type="password"], form.clear_inputs textarea').clearInputs();
  jQuery('form input.clear_password_inputs').swapPasswordInputs();
  jQuery('.date_input').formatDate();
  jQuery('.dollar_prefix').dollarPrefix();
  jQuery('#donation-amount').updateTotalDonationAmount();
});

$(function () {
  var $lastAmount = undefined;
  var $suggestedAmounts = {}
  var $pickers = $('[data-suggested-amount]');
  var $linkedBox = $('[data-linked-box]');
  var $defaultVal = $linkedBox.val();

  if ($defaultVal !== undefined) {
    $('[data-linked-label]').text($defaultVal);
  }

  $pickers.each(function () {
    var $el = $(this);
    var $amount = '';
    if ($el.data("suggestedAmount") != '') {
      $amount = $el.data("suggestedAmount").toFixed(2);
    }

    $suggestedAmounts[$amount] = $el;

    $el.on("click", function () {
      $(this).addClass("btn-donation");
      if ($lastAmount != undefined) {
        $lastAmount.removeClass('btn-donation');
      }
      $lastAmount = $(this);
      $linkedBox.focus();
      $linkedBox.val($amount).trigger('change');
    });
  });

  $linkedBox.on("change", function () {
    if ($lastAmount != undefined) {
      $lastAmount.removeClass('btn-donation');
      $lastAmount = undefined;
    }
    var $dispAmnt = '';

    if (!isNaN(parseFloat($linkedBox.val())) && $linkedBox.val().trim() != '' && $linkedBox.val().match(/^\d+(\.\d+)?$/)) {
      $linkedBox.val(parseFloat($linkedBox.val()).toFixed(2));
      $dispAmnt = $linkedBox.val();
    }
    if ($linkedBox.val().trim() == '') {
      $linkedBox.val('');
      $dispAmnt = $defaultVal;
    }

    if ($suggestedAmounts[$linkedBox.val()] != undefined) {
      $suggestedAmounts[$linkedBox.val()].addClass('btn-donation');
      $lastAmount = $suggestedAmounts[$linkedBox.val()];
    } else if ($suggestedAmounts[''] != undefined) {
      $suggestedAmounts[''].addClass('btn-donation');
      $lastAmount = $suggestedAmounts[''];
    }
    if (!isNaN(parseFloat($dispAmnt))) {
      $dispAmnt = '$' + $dispAmnt;
    }
    $('[data-linked-label]').text($dispAmnt);
  });
  $linkedBox.trigger('change');
});


$(function () {
  $('#submit-donation').click(function (e) {
    var isValid = $('#donation_form').valid();
    var isValid2 = $(document).triggerHandler('validation:required');
    if (isValid) {
      if (isValid2 == false) {
          e.stopPropagation();
          return false;
      }
      else {
          var res = $(document).triggerHandler('confirmation:required');
          if (res == false) {
            e.stopPropagation();
            return false;
          }
          else {
            var res = $(document).triggerHandler('registration:required');
            if (res == false) {
              e.stopPropagation();
              return false;
            }
            else {
              submitDonation();
            }
          }
      }
    }
  });

});

function submitDonation() {
  stripCommasFromDonationAmount();
  $(".loading-modal").addClass("loading");
}

$(function () {
  $("#card_number").keyup(function() {
    var cardValue = $("#card_number").val();
    var cardType = $.payment.cardType(cardValue);
    if (cardType == null) {
      $('.cards').addClass('deselected');
    } else {
      $('#' + cardType).removeClass('deselected');
    }
    if ($('#card_number').val().charAt(0) == 3) {
      $('#card_number').mask('0000 000000 00000');
      $('#cvv').mask('0000');
      $('#credit-card-cvv').addClass('hide');
      $('#amex-cvv').removeClass('hide');
      $("[name='cvv']").attr('placeholder', 'eg. 1234');
    } else {
      $('#card_number').mask('0000 0000 0000 0000');
      $('#cvv').mask('000');
      $('#amex-cvv').addClass('hide');
      $('#credit-card-cvv').removeClass('hide');
      $("[name='cvv']").attr('placeholder', 'eg. 123');
    }
  });

  $("#card_number").blur(function() {
    var cardValue = $('#card_number').val();
    var valid = $.payment.validateCardNumber(cardValue);
    if (valid == false) {
      $('#card_number').css('border', '1px solid red');
    }
  });

  $("#card_number").focus(function() {
    $('.bottom-medium img').addClass('deselected');
    $('#card_number').removeAttr('style');
  });
});

function calcExpressionField(expression, isAmt, target_field_elem_id, target_label_elem_id) {
  var res = expression.match(/<\d+>/g);
  var result = 0;
  try {
    for (var i = 0; i < res.length; i++) {
      var fld_id = res[i].replace(/</g, '').replace(/>/g, '');
      var fld_val =  getCustomElementFrom("custom_fields_" + fld_id).val();

      if (fld_val != null) {
        fld_val = fld_val.replace('$', '');
        regex = new RegExp('[,]', "g");
        fld_val = fld_val.replace(regex, '');
      }

      fld_val = parseFloat(fld_val);
      var regex = new RegExp(res[i], "g");
      if (isNaN(fld_val)) {
        expression = expression.replace(regex, '<noop>');
      }
      else {
        expression = expression.replace(regex, fld_val);
      }
    }
    regex = new RegExp('[-+*\/]<noop>', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('<noop>[-+*\/]', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('[-+*\/]\\(<noop>\\)', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('\\(<noop>\\)[-+*\/]', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('[-+*\/]\\(\\s+\\)', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('\\(\\s+\\)[-+*\/]', "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('[-+*\/]undefined', "g", "g");
    expression = expression.replace(regex, '');
    regex = new RegExp('[-+*\/]\\(undefined\\)', "g");
    expression = expression.replace(regex, '');

    //console.log(expression);
    result = eval(expression);
    result = isAmt ? parseFloat(result).toFixed(2) : parseInt(result);
  }
  catch (err) {
    result = 0;
  }
  getCustomElementFrom(target_field_elem_id).val(result);
  var result_str = (isAmt && result <= 0) ? '0.00' : (result + '');
  if (isAmt)
    result_str = '$' + result_str;
  getCustomElementFrom(target_label_elem_id).html(result_str);
};


function bindCalcExpressionFieldToOperandFieldElemsOnBlur(expression, isAmt, target_field_elem_id, target_label_elem_id) {
  var res = expression.match(/<\d+>/g);
  for (var i = 0; i < res.length; i++) {
    var fld_id = res[i].replace(/</g, '').replace(/>/g, '');
    getCustomElementFrom("custom_fields_" + fld_id).blur(function () {
      return calcExpressionField(expression, isAmt, target_field_elem_id, target_label_elem_id);
    });
  }
}

function getCustomElementFrom(fld_id) {
  return $("[id^='" + fld_id +"']");
}

$('#donation_form').validate();
