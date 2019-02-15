$(document).ready(function() {
  var $show_constituent_list, loadTable;
  setTooltip();
  loadTable = function(url) {
    blockTable();
    return $.ajax({
      url: url,
      method: 'GET',
      format: 'script'
    }).done(function(data) {
      updateContent(null, data);
    }).fail(function(a, b, error) {
      alert(error);
    });
  };
  $show_constituent_list = $('#show_constituent_list');
  if (!($show_constituent_list.length > 0)) {
    return;
  }
  loadTable($show_constituent_list.data('npos-constituents-path'));
  return true;
});

$(document).on('keydown', function(e) {
  var el, esc, field_id, form_id, nl;
  esc = e.which === 27;
  nl = e.which === 13;
  el = e.target;
  if (el.hasAttribute("contenteditable")) {
    if (esc) {
      document.execCommand('undo');
      return el.blur();
    } else if (nl) {
      field_id = el.getAttribute('data-field');
      form_id = el.getAttribute('data-form');
      $('input[id=' + field_id + ']').val($(el).text().trim());
      $('form[id=' + form_id + ']').submit();
      el.blur();
      return e.preventDefault();
    }
  }
});

$(document).on('content-updated', function() {
  if ($('#constituent_list_search').length > 0) {
    unBlockTable();
    setTooltip();
    setSearchForm();
    return $('.fadethisout').delay(4000).fadeOut();
  }
});

window.setTooltip = function() {
  return $('.constituent-list-table').tooltip({
    selector: '[data-toggle=tooltip]'
  });
};

window.unBlockTable = function() {
  return $('.loading-modal').removeClass("loading");
};

window.blockTable = function() {
  return $('.loading-modal').addClass("loading");
};

window.setSearchForm = function() {
  $('#constituent_list_search').off('submit');
  return $('#constituent_list_search').on('submit', function() {
    return blockTable();
  });
};