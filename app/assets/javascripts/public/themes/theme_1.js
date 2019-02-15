$(function() {
  var donateButton = $('#donate-button');
  var navbarDonateButton = $('#navbar-donate');
  var navbarText = $('.navbar-text');

  function showOrHideNavbarDonateButton() {
    var y = $(window).scrollTop();
    if (y > donateButton.offset().top) {
      navbarText.addClass("smaller");
      navbarDonateButton.show();
    } else {
      navbarDonateButton.hide();
      navbarText.removeClass("smaller");
    }
  }

  $(document).scroll(function() {
    showOrHideNavbarDonateButton();
  });
  showOrHideNavbarDonateButton();
});