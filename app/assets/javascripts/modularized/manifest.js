//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap
//= require plugins/jquery-datepicker-monkeypatch
//= require plugins/jquery_inline_date_formatter
//= require jquery-fileupload/basic
//= require modernizr-1.7.min
//= require ../plugins/checkbox_disable
//= require ../plugins/jquery.validate.min
//= require ../plugins/jquery.mask.min
//= require ../plugins/jquery.payment.min
//= require ../plugins/additional-methods.min
//= require ../plugins/payment_form
//= require ../plugins/date.validate
//= require ../widgets/widget_config
//= require ../lib/remote_content.js
//= require ../lib/download_requests.js
//= require ../plugins/multi-select
//= require ../plugins/bootbox.min
//= require ../plugins/Jcrop.min
//= require Chart
//= require jquery.blockUI
//= require moment
//= require_directory .
//= require_self


$(function() {
  $(document).on('content-updated', function() {
    $('[data-tooltip="true"]').tooltip();

    var hash = window.location.hash;
    $('a[href="' + hash + '"]').tab('show');

    var current_time_zone, default_value;
  });
  $(document).on('mc-fadeout', function() {
    var elements;
    elements = $('[data-trigger-fadeout="true"]');
    return elements.each(function() {
      var col_span, config_element, contentKey, duration, el_to_remove, parent, postFadeoutMsg, tr_left;
      config_element = $(this);
      contentKey = config_element.attr('data-fadeout-id');
      if (typeof contentKey !== 'undefined') {
        el_to_remove = $('#' + contentKey);
        if (el_to_remove.length > 0) {
          duration = el_to_remove.data("fadeout-time") ? el_to_remove.data("fadeout-time") : 400;
          if (true === el_to_remove.is("TR")) {
            parent = el_to_remove.parents().get(0);
            tr_left = parent.children.length;
            if (tr_left > 1) {
              return el_to_remove.children('td').animate({
                opacity: 0,
                "padding-top": 0,
                "padding-bottom": 0
              }).wrapInner('<div />').children().slideUp(duration, function() {
                return el_to_remove.remove();
              });
            } else if (tr_left === 1) {
              postFadeoutMsg = el_to_remove.attr('data-post-fadeout-message');
              if (typeof postFadeoutMsg === 'undefined') {
                postFadeoutMsg = "There is no data to show.";
              }
              col_span = el_to_remove.children('td').length;
              return el_to_remove.children('td').animate({
                opacity: 0,
                "padding-top": 0,
                "padding-bottom": 0
              }).wrapInner('<div />').children().slideUp(duration, function() {
                if (postFadeoutMsg !== '') {
                  return el_to_remove.html("<td colspan=" + col_span + "><em>" + postFadeoutMsg + "</em></td>");
                }
              });
            }
          } else {
            return $('#' + contentKey).fadeOut(duration, function() {
              return el_to_remove.remove();
            });
          }
        }
      }
    });
  });
  $('.order_history_link').on('click', function() {
    return history.pushState({}, '', '/account#panel_order_history');
  });
  $('#donation-form-phone-preview').affix({
    offset: {
      top: function() {
        container = $(".fundraiser_container");
        if (container.length == 0) {
          container = $(".tab-pane");
        }
        return container.offset().top - 50;
      }
    }
  });
  $(document).tooltip({
    selector: '[data-toggle=tooltip]',
    container: 'body'
  });
  $(document).popover({
    selector: '[data-toggle=popover]',
    trigger: 'click',
    placement: 'right',
    template: '<div class="popover"><div class="arrow"></div><h3 class="popover-title" style="display: none"></h3><div class="popover-content"></div></div>',
    container: 'body'
  });
  $('[data-toggle=popover]').on('blur', function() {
    return $(this).popover('hide');
  });
  $('.count-characters').displayRemainingCharactersCount();
  $('.date_input').formatDate();
  $('#messaging_sub_type').on('change', function() {
    if ($(this).val() === "autoresponse") {
      return $(".autoresponse_message").collapse('show');
    } else {
      return $(".autoresponse_message").collapse('hide');
    }
  });
  $("body").on('click', 'a[data-popup]', function(e) {
    window.open($(this).attr('href'), '_blank', 'toolbar=no,location=no,menubar=no,scrollbars=yes,resizable=no,height=320px,width=820px');
    return e.preventDefault();
  });
  $("body").on('click', 'a[data-modal]', function(e) {
    var $modal_id, modal_id;
    modal_id = $(this).attr('data-modalId');
    if (modal_id !== void 0) {
      $modal_id = $('#' + modal_id);
    }
    if ($modal_id !== void 0) {
      e.preventDefault();
      return $("#" + modal_id + " .modal-body").load($(this).attr('href'), function() {
        $modal_id.modal({
          backdrop: 'static',
          keyboard: true,
          show: true
        });
        $(document).trigger('content-updated');
      });
    }
  });
  $(document).ready(function() {
    if ($('#messaging_sub_type').val() === "autoresponse") {
      return $(".autoresponse_message").collapse('show');
    } else {
      return $(".autoresponse_message").collapse('hide');
    }
  });
  $(document).trigger('content-updated');
  return $('.validate_mc_form').click(function() {
    var form, isValid;
    form = $(this).closest('form');
    isValid = form.valid();
    if (isValid) {
      return stripCommasFromDonationAmount();
    }
  });
});
