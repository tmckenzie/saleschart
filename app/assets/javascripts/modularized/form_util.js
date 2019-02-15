$(document).ready(function() {
  var copyToClipboard = function(elementId) {
    var aux;
    aux = document.createElement('input');
    aux.setAttribute('value', $(elementId).contents().text());
    document.body.appendChild(aux);
    aux.select();
    document.execCommand('copy');
    document.body.removeChild(aux);
    return
  };
  window.copyToClipboard = copyToClipboard

  var addHttpPrefixToUrl = function($el) {
    var origVal = $el.val().trim();
    if (origVal != '' && origVal.search(/^http[s]?\:\/\//) == -1) {
      $el.val('http://' + origVal);
    }
  }
  window.addHttpPrefixToUrl = addHttpPrefixToUrl
});

function resizeEmbeddedIframe(obj) {
  new_height = obj.contentWindow.document.body.scrollHeight - 200;
  new_code = $('#embedded_code').text().replace(/height="\d+"/, 'height="' + new_height + '"');
  $('#embedded_code').text(new_code);
}