var afterUpload, beforeUpload, setupUploadBlock;

beforeUpload = function(e) {
  e.data.$target.block({
    message: null
  });
  return e.data.$button.val(e.data.$button.data('blocked-label'));
};

afterUpload = function(e) {
  e.data.$button.val(e.data.$button.data('unblocked-label'));
  return e.data.$target.unblock();
};

setupUploadBlock = function() {
  var $button, $el, data;
  $el = $('[data-constituent-list-block-button]:first');
  $button = $el.find($el.data('constituent-list-block-button'));
  return data = {
    $target: $el,
    $button: $button
  };
};

$(document).on('content-updated', function() {
  var data;
  data = setupUploadBlock();
  return data.$target.find('form').each(function() {
    var $form;
    $form = $(this);
    $form.off('ajax:before', beforeUpload).on('ajax:before', data, beforeUpload);
    return $form.off('ajax:complete', afterUpload).on('ajax:complete', data, afterUpload);
  });
});

$(document).ready(function() {
  window.renderAlert = function(data_content_key, message, status) {
    showAlertMsg($('[data-content-key=' + data_content_key + ']'), message, status);
    return $(document).trigger('content-updated');
  };
  return window.showAlertMsg = function($element, message, status) {
    var el;
    el = $('<div></div>');
    el.addClass('alert').addClass(status);
    el.html(message);
    return $element.html(el);
  };
});

$(function() {
  var blockData, fileuploadEvents;
  blockData = setupUploadBlock();
  fileuploadEvents = {
    fileuploadadd: function(e, data) {
      var manualUploadClickHandler;
      manualUploadClickHandler = function(e) {
        e.preventDefault();
        return data.submit();
      };
      return $('#btn-upload').off('click').one('click', manualUploadClickHandler);
    },
    fileuploadstart: function(e) {
      return beforeUpload({
        data: blockData
      });
    },
    fileuploaddone: function(e, data) {
      var file;
      file = data.files[0];
      renderAlert('file-upload-status', "<button type='button' class='close' data-dismiss='alert'>&times;</button><h5>Your list is almost done!</h5><small>Your list has been uploaded and it's processing in the background. It might take a few minutes, so we will email you when it is ready.</small>", "alert alert-success");
      return afterUpload({
        data: blockData
      });
    },
    fileuploadfail: function(e, data) {
      var file;
      file = data.files[0];
      renderAlert('file-upload-status', "Upload failed for file " + file.name + ". " + data.jqXHR.responseText, "alert-danger");
      return afterUpload({
        data: blockData
      });
    }
  };
  return $('#fileupload [data-fileupload]').each(function() {
    var $file_field, event, handler, results;
    $file_field = $(this);
    results = [];
    for (event in fileuploadEvents) {
      handler = fileuploadEvents[event];
      results.push($file_field.off(event, handler).on(event, handler));
    }
    return results;
  });
});
