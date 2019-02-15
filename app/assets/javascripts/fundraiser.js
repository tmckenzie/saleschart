//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require ./plugins/jquery.validate.min
//= require bootstrap
//= require modularized/manifest

$(document).ready(function() {
  var $message, c_message, char_count, collapse, collapsed, length, message;
  char_count = 0;
  if (/android|iphone|ipad|blackberry|opera mini|nokia/i.test(navigator.userAgent.toLowerCase())) {
    char_count = 300;
  } else {
    char_count = 300;
  }
  $message = $(".fundraiser_user_message");
  message = $message.text();
  length = message.length;
  c_message = $message.html();
  collapsed = false;
  collapse = function() {
    var c, html;
    c = message.substr(0, char_count);
    html = c + "... <span class='moreLess'><i class='fa fa-chevron-circle-down'></i></span>";
    collapsed = true;
    return $message.html(html);
  };
  if (length > char_count) {
    collapse();
    return $(".fundraiser_user_message").on("click", function() {
      if (collapsed) {
        $message.html(c_message + "&nbsp; <span class='moreLess'><i class='fa fa-chevron-circle-up'></i></span>");
        return collapsed = false;
      } else {
        return collapse();
      }
    });
  }
});
