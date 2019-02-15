$(document).ready(function() {
    $('#add-note textarea').keyup(function() {
      if ($(this).val() == '') {
        $('#add-note input[type="submit"]').attr('disabled', 'disabled');
      }
      else {
        $('#add-note input[type="submit"]').removeAttr('disabled');
      }
    });

    $('#submit_donation_button').click(function(){
      $(".loading-modal").addClass("loading");
    });
});
