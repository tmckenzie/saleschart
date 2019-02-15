// regarding the markup and styles, see http://www.quirksmode.org/dom/inputfile.html
// regarding the fileuploadadd and fileuploaddone events and data object, see http://github.com/blueimp/jQuery-File-Upload

var clearFilename, clearLoading, fileuploaddone, fileuploaddrop, fileuploadfail, fileuploadsubmit, isAcceptableType, showFilename, showLoading;

function load_image_cropper(model_name, model_id, img_name) {
  var $img_cropper = $('#image_cropper_modal');
  if ($img_cropper !== "undefined") {
    var orig_loading_text = $('.loading-text').text();
    $('.loading-text').text('Preparing Image for Cropping');
    var cropper_url = "/image_crop/" + model_name + "/" + model_id + "/" + img_name + ".js";
    $("#image_cropper_modal .modal-body").load(cropper_url, function () {
      $img_cropper.modal({
        backdrop: 'static',
        keyboard: true,
        show: true
      });
      $(".loading-modal").removeClass("loading");
      $('.loading-text').text(orig_loading_text);
    });
  }
}

isAcceptableType = function(data, accept) {
  var i, pat, result, size;
  result = {
    isFound: true,
    fileName: ''
  };
  size = data.files.length;
  i = 0;
  pat = new RegExp('^' + accept, "i");
  while (i < size) {
    if (!pat.test(data.files[i].type)) {
      result.isFound = false;
      result.fileName = data.files[i].name;
      break;
    }
    ++i;
  }
  return result;
};

showFilename = function(e, data) {
  var filename;
  filename = data.files[0].name;
  return $(e.data.fakefile).val(filename);
};

fileuploadsubmit = function(e, data) {
  var elErr;
  elErr = $("[data-file-upload-error='" + this.id + "']").length > 0;
  if (e.data.accept.attr("accept") && !isAcceptableType(data, this.accept).isFound) {
    clearLoading(e, data);
    if (elErr) {
      $("[data-file-upload-error='" + this.id + "']").show();
    }
    return e.preventDefault();
  } else {
    if (elErr) {
      $("[data-file-upload-error='" + this.id + "']").hide();
    }
    return $(document).trigger("fileUpload:submit");
  }
};

showLoading = function(e, data) {
  var $fakefile;
  $fakefile = $(e.data.fakefile);
  if (e.data.cropafterupload === "true") {
    return $(".loading-modal").addClass("loading");
  } else {
    return $fakefile.siblings("[data-loading=" + ($fakefile.data('fakefile')) + "]").show();
  }
};

clearFilename = function(e, data) {};

clearLoading = function(e, data) {
  var $fakefile;
  $fakefile = $(e.data.fakefile);
  if (e.data.cropafterupload !== "true") {
    return $fakefile.siblings("[data-loading=" + ($fakefile.data('fakefile')) + "]").hide();
  }
};

fileuploaddrop = function(e, data) {
  var check, elErr;
  elErr = $("[data-file-upload-error='" + this.id + "']").length > 0;
  if (e.data.accept.attr("accept")) {
    check = isAcceptableType(data, this.accept);
    if (check.isFound) {
      if (elErr) {
        return $("[data-file-upload-error='" + this.id + "']").hide();
      }
    } else {
      $(e.data.fakefile).val(check.fileName);
      if (elErr) {
        $("[data-file-upload-error='" + this.id + "']").show();
      }
      return e.preventDefault();
    }
  }
};

fileuploaddone = function(e, data) {
  var $img_cropper, crop_attrs, cropper_url;
  if (e.data.callbackTagId !== "undefined") {
    $('#' + e.data.callbackTagId).val(data.result.id);
  }
  if (e.data.cropafterupload === "true") {
    if (e.data.cropattrs !== void 0) {
      crop_attrs = e.data.cropattrs.split(",");
      load_image_cropper(crop_attrs[0], crop_attrs[1], crop_attrs[2]);
    }
    else if (data.result.crop_attrs !== void 0) {
      crop_attrs = data.result.crop_attrs;
      load_image_cropper(crop_attrs.model_name, crop_attrs.model_id, crop_attrs.image_name);
    }
    else {
      $(".loading-modal").removeClass("loading");
    }
  }
  $(document).trigger("fileUpload:done", [data.result.id, data.result.name]);
  if (e.data.target !== "undefined" && e.data.signal !== "undefined") {
    return $('#' + e.data.target).trigger(e.data.signal);
  }
};

fileuploadfail = function(e, data) {
  var file;
  file = data.files[0];
  $(".loading-modal").removeClass("loading");
  if (e.data.uploadStatusKey !== "undefined") {
    renderAlert(e.data.uploadStatusKey, "Upload failed for file " + file.name + ". " + data.jqXHR.responseText, "alert-danger");
  }
  return $(document).trigger("fileUpload:fail");
};

$(document).on('drop dragover', function(e) {
  return e.preventDefault();
});

$(document).on('ready', function() {
  $('#dummy-file-input').click(function () {
    $('#file-upload').trigger('click');
  });
});

$(document).on('content-updated', function() {
  return $('[data-fileupload]').each(function() {
    var $file_field, config, data;
    $file_field = $(this);
    ({
      accept: $file_field.context.accept
    });
    data = {
      fakefile: "[data-fakefile=" + ($file_field.data('fileupload')) + "]",
      accept: $file_field,
      signal: "" + ($file_field.attr('data-trigger-signal')),
      target: "" + ($file_field.attr('data-signal-target')),
      callbackTagId: "" + ($file_field.attr('data-callback-tag-id')),
      uploadStatusKey: "" + ($file_field.attr('data-upload-status-key')),
      cropafterupload: "" + ($file_field.attr('data-crop-image')),
      cropattrs: $file_field.attr('data-crop-image-attrs')
    };
    config = {
      dropZone: $file_field,
      dataType: 'json'
    };
    if ($file_field.data('fileupload-method') === 'manual') {
      config.add = function(e, data) {};
    }
    $file_field.fileupload(config);
    $file_field.off('fileuploadadd', showFilename).on('fileuploadadd', data, showFilename);
    $file_field.off('fileuploaddone', clearFilename).on('fileuploaddone', data, clearFilename);
    $file_field.off('fileuploaddrop', fileuploaddrop).on('fileuploaddrop', data, fileuploaddrop);
    $file_field.off('fileuploaddone', fileuploaddone).on('fileuploaddone', data, fileuploaddone);
    $file_field.off('fileuploadsubmit', fileuploadsubmit).on('fileuploadsubmit', data, fileuploadsubmit);
    $file_field.off('fileuploadfail', fileuploadfail).on('fileuploadfail', data, fileuploadfail);
    if ($file_field.data('add-loading-ui')) {
      $file_field.off('fileuploadadd', showLoading).on('fileuploadadd', data, showLoading);
      $file_field.off('fileuploaddone', clearLoading).on('fileuploaddone', data, clearLoading);
      return $file_field.off('fileuploadfail', clearLoading).on('fileuploadfail', data, clearLoading);
    }
  });
});
