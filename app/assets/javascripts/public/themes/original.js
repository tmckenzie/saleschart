$(document).ready(function() {
  var $message, c_message, char_count, collapse, collapsed, length, message;
  char_count = 300;
  $message_element = $(".fundraiser_user_message");
  message = $message_element.text();
  length = message.length;
  c_message = $message_element.html();
  collapsed = false;
  collapse = function() {
    var c, html;
    c = message.substr(0, char_count);
    html = c + "... <span class='moreLess'><i class='fa fa-chevron-circle-down'></i></span>";
    collapsed = true;
    return $message_element.html(html);
  };
  if (length > char_count) {
    collapse();
    return $(".fundraiser_user_message").on("click", function() {
      console.log(collapsed);
      if (collapsed) {
        $message_element.html(c_message + "&nbsp; <span class='moreLess'><i class='fa fa-chevron-circle-up'></i></span>");
        return collapsed = false;
      } else {
        return collapse();
      }
    });
  }
});
