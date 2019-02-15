$(document).ready(function () {

  // This makes the "All Lists" checkbox work on the template schedule page
  $(document).on('content-updated', function () {
    $("input#select_all_lists_for_messages_check_box").click(function (e) {
      $(this).parents("form:first").find("[id^=constituent_list_ids]").prop('checked', $(this).prop('checked'));
    });
  });

  // For NPO Admin clickable wells
  $("[data-clickable='well']").each(function () {
    // Change the cursor and background-color on hover
    $(this).hover(function () {
          $(this).css('cursor', 'pointer');
          $(this).addClass('well-hover-background');
          return false;
        },
        function () {
          $(this).css('cursor', 'default');
          $(this).removeClass('well-hover-background');
          return false;
        }
    );

    // Make the div clickable
    $(this).click(function (e) {
      $(".loading-modal").addClass("loading");
      window.location.href = $(e.currentTarget).find("#clickable_link").attr('href');
    });
  });
  // end of clickable wells code

});