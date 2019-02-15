$(function() {
  return $(document).ready(function() {
    $('[data-align]').each(function() {
      return $(this).on('click', function() {
        $('#bg_img_orient').val($(this).data("align"));
        return $('#bg_img_orient').trigger('change');
      });
    });

    $('[data-text]').each(function() {
      return $(this).on('change', function() {
        if (this.checked) {
          return $('#' + $(this).data('text')).css("color", "transparent");
        } else {
          return $('#' + $(this).data('text')).css("color", "initial");
        }
      });
    });

    $("#donation_form_submit_btn").on('click', function() {
      ajax_save_button_styler(this.closest("form").attr('action'), $(this));
      return false;
    });

    $('.button-tile-alignment').on('click', function() {
      $(this).addClass('current').siblings().removeClass('active');
    });

    return $("#donation_form_save_btn").on('click', function() {
      $('.form-input-error-message').hide();
      ajax_save_button_styler($(this).attr('href'), $(this));
      return false;
    });
  });
});