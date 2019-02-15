$(document).ready(function() {
  // For convenience
  var m = moment;

  // Move active status to current button
  var setCurrentActiveDateButton = function(currentButton) {
    $('#date-quick-select').children().removeClass('active');
    currentButton.addClass('active');
  };

  // Set dates in start and end date fields
  var setDateFieldsToRange = function(startDate, endDate) {
    $('#search_start_date').val(startDate.format('MM/DD/YYYY'));
    $('#search_end_date').val(endDate.format('MM/DD/YYYY'));

    // Reset time if use clicked a quick search button
    $('#search_start_date_hour').val('00');
    $('#search_start_date_minute').val('00');
    $('#search_end_date_hour').val('23');
    $('#search_end_date_minute').val('59');
  };

  // Set all the dates and buttons properly if the user clicks one of our date presets
  var handlePresetDateButtonClick = function(event, startDate, endDate) {
    // Prevents the page from jumping to the top on click
    event.preventDefault();

    // Prevents any parent event handlers from being notified of this event
    event.stopPropagation();

    setDateFieldsToRange(startDate, endDate);
    setCurrentActiveDateButton($(event.target));
  };

  var customDateFields = '#search_start_date, #search_start_date_hour, #search_start_date_minute,' +
                         '#search_end_date, #search_end_date_hour, #search_end_date_minute'
  $(customDateFields).click(function(e) {
    setCurrentActiveDateButton($('.custom_link'))
  });

  $('.today_link').click(function(e) {
    handlePresetDateButtonClick(e, m().startOf('day'), m().endOf('day'));
  });

  $('.past_seven_days').click(function(e) {
    // We only subtract 6 here because we want to include today
    handlePresetDateButtonClick(e, m().subtract(6, 'days'), m());
  });

  $('.past_thirty_days').click(function(e) {
    // We only subtract 29 here because we want to include today
    handlePresetDateButtonClick(e, m().subtract(29, 'days'), m());
  });

  $('.this_month_link').click(function(e) {
    handlePresetDateButtonClick(e, m().startOf('month'), m().endOf('month'));
  });

  $('.last_month_link').click(function(e) {
    handlePresetDateButtonClick(e, m().subtract(1, 'month').startOf('month'), m().subtract(1, 'month').endOf('month'));
  });

  $('.this_year_link').click(function(e) {
    handlePresetDateButtonClick(e, m().startOf('year'), m().endOf('year'));
  });

  $('.last_year_link').click(function(e) {
    handlePresetDateButtonClick(e, m().subtract(1, 'year').startOf('year'), m().subtract(1, 'year').endOf('year'));
  });

  $('.custom_link').click(function(e) {
    var startDate = m($('#search_start_date').val(), 'MM/DD/YYYY');
    var endDate = m($('#search_end_date').val(), 'MM/DD/YYYY');
    handlePresetDateButtonClick(e, startDate, endDate);
  })

  $('input.search_date[type=checkbox]').click(function(e) {
    if(this.checked) {
      $('.date_options').removeClass('hide');
    } else {
      $('.date_options').addClass('hide');
    }
  });
});
