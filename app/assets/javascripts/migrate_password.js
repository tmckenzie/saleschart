(function(){
  function goto(event) {
    var $goto = $('[data-goto]');
    if ($goto.length) {
      var location = $goto.data('goto');
      if (location.length > 0) {
        window.location = location;
      }
    }
    else {
      $('#migrate_password').dialog({
        autoOpen:true,
        width:'inherit',
        modal:true
      });
    }
  }
  $(document).bind('content-updated', goto);
  $(goto);
})();
