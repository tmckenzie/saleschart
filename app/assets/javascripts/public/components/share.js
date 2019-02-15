$(function() {
  var $hideShareLinks = $(".share-links-hide");
  var $showShareLinks = $(".share-links-show");
  var $shareLinks = $(".share-links");

  $hideShareLinks.click(function() {
    $shareLinks.addClass("slideOutLeft");
    $showShareLinks.show();
  });

  $showShareLinks.click(function() {
    $shareLinks.removeClass("slideOutLeft");
    $showShareLinks.hide();
  });

  $shareLinks.find(".share-link").click(function() {
    $(this).blur();
  });
});