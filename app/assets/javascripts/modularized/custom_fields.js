$(document).ready(function() {

  /*
   Execute this only if custom field template forms are present
   */
  var configureDependantFields, configureLimitFields, copyItemName, insertDropDownRowAbove, load_custom_fields_calc_selector, load_custom_fields_concat_selector, load_custom_fields_selectors, newDropdownRow, new_dropdown_item_row, readSingleFile, removeDropdownRow, reorderDropdownIndexes, undoLastExpression, validateExpression;

  if ($('[data-custom-field-template-form]').length < 0) {
    return;
  }

  $(".open_custom_section_modal_on_click").on('click', function() {
    if ($('[data-addSectionError]').attr('data-addSectionError') === 'true' && $('[data-unsaved-flag]').attr('data-unsaved-flag') === 'true') {
      return $('[data-addSectionError]').removeClass('hide');
    } else {
      $('[data-addSectionError]').addClass('hide');
      return $("#add_custom_section_modal").modal({
        keyboard: true,
        show: true
      });
    }
  });

  $(".open_receipt_config_modal_on_click").on('click', function() {
    if ($('[data-addSectionError]').attr('data-addSectionError') === 'true' && $('[data-unsaved-flag]').attr('data-unsaved-flag') === 'true') {
      return $('[data-addSectionError]').removeClass('hide');
    } else {
      $('[data-addSectionError]').addClass('hide');
      return $("#add_receipt_config_modal").modal({
        keyboard: true,
        show: true
      });
    }
  });

  $(".open_custom_field_modal_on_click").on('click', function() {
    var section_id;
    section_id = $(this).attr('data-sectionId');
    $('.section_id_for_add_new_field').each(function() {
      return $(this).val(section_id);
    });
    return $("#add_custom_form_field_modal").modal({
      backdrop: 'static',
      keyboard: true,
      show: true
    });
  });

  $('#control_type_selection').on('change', function(e) {
    $('#control_type_selector').addClass('hide');
    configureLimitFields($(this).val() + "_0");
    $('#' + $(this).val()).removeClass('hide');
    $('#control_type').val($(this).val());
    if ($(this).val() != 'image') {
      $('#save_custom_field').removeClass('hide');
    }
  });

  $('#save_custom_field').on('click', function() {
    var btn = $('#save_custom_' + $('#control_type_selection').val());
    if (btn.closest('form').valid()){
      $('#control_type_selection').val('');
      return btn.click();
    }
  });

  $('#add_section').on('click', function() {
    var btn;
    btn = $('#add_custom_section');
    return btn.click();
  });

  $('#move_section').on('click', function() {
    var btn;
    btn = $('#move_custom_section');
    return btn.click();
  });

  /*   * Reset modal when cancelled
   */
  $('#cancel_custom_field').on('click', function() {
    var flag;
    $('#control_type_selector').removeClass('hide');
    $('#control_type_selection').val('');

    /*     * flag to not remove the first element */
    flag = false;
    $(".dropdown_row0").each(function() {
      if (flag === true) {
        $(this).remove();
      }
      flag = true;
    });
  });

  $('#add_custom_form_field_modal').on('hidden.bs.modal', function(e) {
    var flag;
    $('#control_type_selector').removeClass('hide');
    $('#control_type_selection').val('');

    /*     * flag to not remove the first element */
    flag = false;
    $(".dropdown_row0").each(function() {
      if (flag === true) {
        $(this).remove();
      }
      flag = true;
    });


    $('[data-custom-field-template-form] input[type=text]').each(function() {
      return $(this).val('');
    });

    $('[data-custom-field-template-form] textarea').each(function() {
      return $(this).val('');
    });

    $('#custom_control_values_value').val('');
    $(".dropdown_row0:first [data-dropdown-item-name]").val('');
    $(".dropdown_row0:first [data-dropdown-item-value]").val('');
    $('.mdd_dropdown').each(function() {
      return $(this).val('');
    });

    $('.control_selector_panel').each(function() {
      $(this).addClass('hide');
    });

    $('[data-content-key=add-custom-field-form-errors]').empty();
    $('#save_custom_field').addClass('hide');
    $('.advanced_options0').addClass('hide');
    load_custom_fields_selectors();

    /*     * reset all calc fields */
    $('[id^=calc_expression_display]').val('');
    $('[id^=calc_expression]').val('');
    $('[id^=calc_list]').val('');
    $('.numeric_custom_field_option').each(function() {
      return $(this).attr('checked', false);
    });
    $('.limit_custom_field_option').each(function() {
      return $(this).attr('checked', false);
    });
    $('.limit_enabled_panel').addClass('hide');
    $('.limit_config').addClass('hide');
    $('#expression_result_type').attr('checked', false);
    $('#dropdown_fileinput0').val('');
  });

  /*   * Reset edit modal on hide */
  $('#edit_custom_form_field_modal').on('hidden', function() {
    $('.limit_custom_field_option').each(function() {
      return $(this).attr('checked', false);
    });

    $('.limit_enabled_panel').addClass('hide');
    $('.limit_config').addClass('hide');
  });

  $('#update_custom_field').on('click', function(e) {
    $('[id^=concat_list] option').prop('selected', true);
    $('#edit_custom_field_form').submit();
  });

  $('[data-custom-field-template-form]').each(function() {
    $(this).on('ajax:success', function(e, data, textStatus, jqXHR) {
      updateContent(null, data);
      load_custom_fields_selectors();
      $('#add_custom_form_field_modal').modal('hide');
    });

    return $(this).on('ajax:error', function(e, xhr, status, error) {
      renderAlert('add-custom-field-form-errors', xhr.responseText, 'alert-danger');
    });
  });

  copyItemName = function($itemObj) {
    var id, val;
    id = $itemObj.attr('data-dropdown-item-name');
    val = $("#custom_control_values_display_value_" + id).val();
    if (val === void 0 || val.trim() === '') {
      $("#custom_control_values_display_value_" + id).val($itemObj.val());
    }
  };

  window.copyItemName = copyItemName;

  new_dropdown_item_row = function(new_row_id, $new_row, row_id, row_name, row_data) {
    var new_id;
    new_id = row_id + '_' + new_row_id;
    $new_row.attr('id', new_id);
    $new_row.attr('name', row_name + '[' + new_row_id + ']');
    $new_row.attr(row_data, new_row_id);
    $new_row.val('');
    return $new_row.on('blur', function() {
      return copyItemName($(this));
    });
  };

  window.new_dropdown_item_row = new_dropdown_item_row;
  newDropdownRow = function(fieldId) {
    var last_row_id, new_row_id;
    last_row_id = $(".dropdown_row" + fieldId + ":last [data-dropdown-item-name]").attr('data-dropdown-item-name');
    $(".dropdown_row" + fieldId + ":last").clone().insertAfter("div.dropdown_row" + fieldId + ":last");
    new_row_id = parseInt(last_row_id) + 1;
    new_dropdown_item_row(new_row_id, $(".dropdown_row" + fieldId + ":last [data-dropdown-item-name]"), 'custom_control_values_display_name', 'custom_control_values[display_name]', 'data-dropdown-item-name');
    new_dropdown_item_row(new_row_id, $(".dropdown_row" + fieldId + ":last [data-dropdown-item-value]"), 'custom_control_values_display_value', 'custom_control_values[display_value]', 'data-dropdown-item-value');
  };

  window.newDropdownRow = newDropdownRow;
  $(document).on('click', '[data-advancedDDLink]', function(event) {
    var fieldId;
    event.preventDefault();
    fieldId = $(this).attr('data-advancedDDLink');
    $('#advanced_options' + fieldId).toggleClass('hide');
    return $('.limit_enabled_panel').removeClass('hide');
  });
  $(document).on('click', '[data-addDDRow]', function(e) {
    var fieldId, last_row_id, new_row_id;
    fieldId = $(this).attr('data-addDDRow');
    last_row_id = $(".dropdown_row" + fieldId + ":last [data-dropdown-item-name]").attr('data-dropdown-item-name');
    $(".dropdown_row" + fieldId + ":last").clone().insertAfter("div.dropdown_row" + fieldId + ":last");
    new_row_id = parseInt(last_row_id) + 1;
    new_dropdown_item_row(new_row_id, $(".dropdown_row" + fieldId + ":last [data-dropdown-item-name]"), 'custom_control_values_display_name', 'custom_control_values[display_name]', 'data-dropdown-item-name');
    new_dropdown_item_row(new_row_id, $(".dropdown_row" + fieldId + ":last [data-dropdown-item-value]"), 'custom_control_values_display_value', 'custom_control_values[display_value]', 'data-dropdown-item-value');
  });
  reorderDropdownIndexes = function(fieldId) {
    $('.dropdown_row' + fieldId).each(function(i) {
      var input1, input2, row;
      row = $('.dropdown_row' + fieldId)[i];
      input1 = $(row).find('input')[0];
      input2 = $(row).find('input')[1];
      $(input1).attr('data-dropdown-item-name', i);
      $(input2).attr('data-dropdown-item-value', i);
      $(input1).attr('id', 'custom_control_values_display_name_' + i);
      $(input1).attr('name', 'custom_control_values[display_name][' + i + ']');
      $(input2).attr('id', 'custom_control_values_display_value_' + i);
      return $(input2).attr('name', 'custom_control_values[display_value][' + i + ']');
    });
  };
  window.reorderDropdownIndexes = reorderDropdownIndexes;
  insertDropDownRowAbove = function(row, last_row_id) {
    var id, new_row;
    new_row = row.clone().insertBefore(row);
    id = parseInt(last_row_id) + 1;
    new_dropdown_item_row(id, $($(new_row).find('input')[0]), 'custom_control_values_display_name', 'custom_control_values[display_name]', 'data-dropdown-item-name');
    new_dropdown_item_row(id, $($(new_row).find('input')[1]), 'custom_control_values_display_value', 'custom_control_values[display_value]', 'data-dropdown-item-value');
  };
  window.insertDropDownRowAbove = insertDropDownRowAbove;
  $(document).on('click', '[data-insertDDRow]', function(e) {
    var fieldId, last_row_id, row;
    fieldId = $(this).attr('data-insertDDRow');
    row = $($(this).parent()).parent().parent(); // TODO fix me please post bootstrap3 upgrade
    last_row_id = $('.dropdown_row' + fieldId + ':last [data-dropdown-item-name]').attr('data-dropdown-item-name');
    insertDropDownRowAbove(row, last_row_id);
    reorderDropdownIndexes(fieldId);
  });
  removeDropdownRow = function(row, fieldId) {
    if ($('.dropdown_row' + fieldId).length > 1) {
      $(row).remove();
      reorderDropdownIndexes(fieldId);
    } else {
      $($(row).find('input')[0]).val('');
      $($(row).find('input')[1]).val('');
    }
  };
  window.removeDropdownRow = removeDropdownRow;
  $(document).on('click', '[data-removeDDRow]', function(e) {
    var fieldId, row;
    fieldId = $(this).attr('data-removeDDRow');
    row = $($(this).parent()).parent().parent();
    removeDropdownRow(row, fieldId);
  });
  $(document).on('click', '[data-removeAllDDRows]', function(e) {
    var fieldId, rows;
    if (confirm("Entire list contents will be cleared, are you sure you want to delete all?")) {
      fieldId = $(this).attr('data-removeAllDDRows');
      rows = $('.dropdown_row' + fieldId);
      rows.each(function(i) {
        return removeDropdownRow(rows[i], fieldId);
      });
    }
  });
  readSingleFile = function(evt, fieldId) {

    /*
     #Retrieve the first (and only!) File from the FileList object
     */
    var f, r;
    f = evt.target.files[0];
    if (f) {
      r = new FileReader;
      r.onload = function(e) {
        var contents;
        contents = e.target.result;
      };
      r.readAsText(f);
      r.onload = function(evt) {
        var lines, ret, text, valid;
        text = evt.target.result;
        ret = validUploadRows(text);
        valid = ret[0];
        if (valid === false) {
          renderAlert('add-custom-field-form-errors', 'Invalid upload file! ' + ret[1], 'alert-danger');
          return false;
        }
        lines = text.split(/[\r\n]+/g);
        $(lines).each(function(i) {
          var array, last_row_id, line, regex, val1, val2;
          if (lines[i] !== '') {
            regex = new RegExp('[\u000d\n]', 'g');
            line = lines[i].replace(regex, '');
            array = CSVRowtoArray(line);
            if (array === null && lines[i] !== null && lines[i].indexOf('\'') > -1) {
              array = lines[i].split(',');
            }
            if (array !== null) {
              val1 = array[0];
              val2 = val1;
              if (array.length > 1) {
                val2 = array[1];
              }
              if ($('.dropdown_row' + fieldId + ':last input')[0].value !== '' || $('.dropdown_row' + fieldId + ':last input')[1].value !== '') {
                newDropdownRow(fieldId);
              }
              $('.dropdown_row' + fieldId + ':last input')[0].value = val1;
              $('.dropdown_row' + fieldId + ':last input')[1].value = val2;
              last_row_id = $('.dropdown_row' + fieldId + ':last [data-dropdown-item-name]').attr('data-dropdown-item-name');
              if (i < lines.length - 1) {
                return newDropdownRow(fieldId);
              }
            }
          }
        });
        $('#dropdown_fileinput' + fieldId).val('');
      };
    } else {
      renderAlert('add-custom-field-form-errors', 'Failed to load file', 'alert-danger');
      return false;
    }
    return true;
  };
  window.readSingleFile = readSingleFile;
  $(document).on('change', '[data-fileInputDD]', function(event) {
    var fieldId;
    fieldId = $(this).attr('data-fileInputDD');
    return readSingleFile(event, fieldId);
  });
  $('[data-dropdown-item-name]').on('blur', function(e) {
    var fieldId;
    copyItemName($(this));
    fieldId = $(this).attr('data-dropdown-item-name');
    if ($('#dependant_field_dropdown_' + fieldId) !== void 0) {
      $('#dependant_field_dropdown_' + fieldId).removeAttr('disabled');
      return $($('#dependant_field_dropdown_' + fieldId).parent()).removeClass('disabled');
    }
  });
  $(document).on('click', '[data-exportDDCSV]', function(event) {
    var csvContent, encodedUri, template_values;
    template_values = JSON.parse($(this).attr('data-exportDDCSV'));
    csvContent = 'data:text/csv;charset=utf-8,';
    $(template_values).each(function(i) {
      var data;
      data = template_values[i].join(',');
      csvContent += data;
      if (i < template_values.length - 1) {
        csvContent += '\n';
      }
    });
    encodedUri = encodeURI(csvContent);
    window.open(encodedUri);
  });
  load_custom_fields_concat_selector = function() {

    /*     * Empty out left side select box for both new and edit fields
     * note: new --> concat_fld_ids0; edit --> concat_fld_ids1122
     */
    var selectOptions, selectOptionsLength;
    $('[id^=concat_fld_ids]').empty();

    /*     * Empty out right side select box for new field
     * note: new --> concat_list0; edit --> concat_list1122
     */
    $('#concat_list0').empty();
    selectOptions = {};
    $('.custom_field').each(function() {
      var display_only, id, label, type;
      id = $(this).attr('data-id');
      label = $(this).attr('data-label');
      type = $(this).attr('data-type');
      display_only = $(this).attr('data-displayOnly');
      if (type !== 'expression' && display_only === 'false') {
        return selectOptions[id + ""] = label;
      }
    });
    selectOptionsLength = Object.keys(selectOptions).length;
    if (selectOptionsLength > 0) {

      /*
       * Fill up the left side select box for new and edit custom fields.
       */
      return $('[id^=concat_fld_ids]').each(function() {
        var $selectField, dependantFieldIds, e, i;
        $selectField = $(this);
        dependantFieldIds = [];
        try {
          dependantFieldIds = JSON.parse($selectField.attr('data-dependantFieldIds'));
        } catch (_error) {
          e = _error;
        }

        /*           * NO-OP
         * console.log e
         */
        i = 0;
        return $.each(selectOptions, function(id, label) {
          if ($.inArray(id, dependantFieldIds) === -1 && $selectField.attr('data-fieldId') !== id) {
            $selectField.append(new Option(label, id));
          }
          return i++;
        });
      });
    }
  };
  load_custom_fields_calc_selector = function() {
    $('[id^=calc_list]').empty();
    $('[id^=calc_list]').append(new Option('Select an available numeric custom field to insert into calculation', ''));
    return $('.custom_field').each(function() {
      var id, is_numeric, label;
      id = $(this).attr('data-customFieldId');
      label = $(this).attr('data-label');
      is_numeric = $(this).attr('data-numeric');
      if (is_numeric === 'true') {
        return $('[id^=calc_list]').append(new Option(label, id));
      }
    });
  };
  load_custom_fields_selectors = function() {
    load_custom_fields_concat_selector();
    return load_custom_fields_calc_selector();
  };
  validateExpression = function(expr) {
    var err, res, str;
    if (expr.indexOf('><') !== -1) {
      return false;
    }

    /*
     * just get the id and use it for our calc
     */
    str = expr.replace(/</g, '').replace(/>/g, '');
    try {
      res = eval(str);
      return true;
    } catch (_error) {
      err = _error;
      return false;
    }
  };
  undoLastExpression = function($expr) {
    var curr_val, del_field, i, operator;
    operator = ['+', '-', '*', '/', '(', ')', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
    curr_val = $expr.val();
    i = curr_val.length - 1;
    del_field = false;
    while (i > 0) {
      if (curr_val[i] === '>') {
        del_field = true;
      }
      if (!del_field && operator.indexOf(curr_val[i]) !== -1) {
        $expr.val(curr_val.slice(0, i));
        return;
      }
      if (curr_val[i] === '<') {
        $expr.val(curr_val.slice(0, i));
        return;
      }
      i--;
    }
    $expr.val(curr_val.slice(0, i));
  };
  configureLimitFields = function(fieldSuffix) {
    var $limitEnabledCb;
    $limitEnabledCb = $('#limit_enabled_' + fieldSuffix);
    if ($('#numeric_' + fieldSuffix).is(':checked') || fieldSuffix.indexOf('dropdown') >= 0 || fieldSuffix.indexOf('calculated') >= 0) {
      $('.limit_enabled_panel').removeClass('hide');
      $limitEnabledCb.attr('disabled', false);
    } else {
      $('.limit_enabled_panel').addClass('hide');
      $limitEnabledCb.attr('checked', false);
      $limitEnabledCb.attr('disabled', true);
    }
    if ($limitEnabledCb.is(':checked')) {
      return $('.limit_config').removeClass('hide');
    } else {
      return $('.limit_config').addClass('hide');
    }
  };
  window.configureLimitFields = configureLimitFields;
  configureDependantFields = function(fieldSuffix) {
    var $dependantFieldEnabledCb;
    $dependantFieldEnabledCb = $('#dependant_field_' + fieldSuffix);
    if ($dependantFieldEnabledCb.is(':checked')) {
      $('#extract_expression_' + fieldSuffix).removeClass('hide');
      $dependantFieldEnabledCb.attr('disabled', false);
      return $dependantFieldEnabledCb.parent().removeClass("disabled");
    } else {
      return $('#extract_expression_' + fieldSuffix).addClass('hide');
    }
  };
  window.configureDependantFields = configureDependantFields;
  return $(document).on('content-updated', function() {
    load_custom_fields_selectors();
    $('#edit_custom_field_form').off('ajax:success').on('ajax:success', function(e, data, textStatus, jqXHR) {
      updateContent(null, data);
      $('#edit_custom_form_field_modal').modal('hide');
    });
    $('#edit_custom_field_form').off('ajax:error').on('ajax:error', function(e, xhr, status, error) {
      renderAlert('edit-custom-field-form-errors', xhr.responseText, 'alert-danger');
    });
    $('[data-calcOperator]').off('click').on('click', function() {
      var $calcExpr, $calcExprDisplay, fieldId, operator;
      fieldId = $(this).attr('data-calcOperator');
      operator = $(this).attr('data-operator');
      $calcExprDisplay = $('#calc_expression_display' + fieldId);
      $calcExpr = $('#calc_expression' + fieldId);
      $calcExprDisplay.val($calcExprDisplay.val() + operator);
      $calcExpr.val($calcExpr.val() + operator);
    });
    $('[data-calcOperand]').off('change').on('change', function() {
      var $calcExpr, $calcExprDisplay, dd_label, fieldId;
      fieldId = $(this).attr('data-calcOperand');
      $calcExprDisplay = $('#calc_expression_display' + fieldId);
      $calcExpr = $('#calc_expression' + fieldId);
      dd_label = $('option:selected', $(this)).text();
      $calcExprDisplay.val($calcExprDisplay.val() + '<' + dd_label + '>');
      $calcExpr.val($calcExpr.val() + '<' + $(this).val() + '>');
      $(this).val('');
    });
    $('[data-undoLastOperation]').off('click').on('click', function() {
      var fieldId;
      fieldId = $(this).attr('data-undoLastOperation');
      undoLastExpression($('#calc_expression_display' + fieldId));
      undoLastExpression($('#calc_expression' + fieldId));
    });
    return $('[data-custom-field-template-form]').off('submit').submit(function(e) {
      var calcExpr, errorTag;
      calcExpr = $(this).find('input[name="expression[calculation]"]').val();
      if (calcExpr === void 0) {
        return;
      }
      if (validateExpression(calcExpr)) {
        return;
      }
      errorTag = $(this).attr('data-errorTag');
      showAlertMsg($('[data-content-key=' + errorTag + ']'), 'Invalid expression! Please check your calculation syntax.', 'alert-danger');
      return false;
    });
  });
});