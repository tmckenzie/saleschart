$(document).ready ->

  # Highlights the column when you hover over a column header dropdown
  $('.column_header').on 'focus hover', ->
    currentColumnId = $(this).parent().attr('data-column')
    $('.column_header').each ->
      columnId = $(this).parent().attr('data-column')
      if columnId == currentColumnId
        highlightColumn(currentColumnId)
      else
        unHighlightColumn(columnId)
    return

  # * Applies disabled look if ignore option is selected on a column header dropdown
  # * Makes sure column header selections are unique on the page:
  #     If user selects a column option that's already selected on a different column,
  #     it changes the other column to ignore and applies disabled look on that column.
  # * Handles 'Add field' option selection:
  #     It pops up the modal dialog.
  #     Changes selection back to previous selection.
  $('.column_header').on 'change', (e) ->
    $currentSelection = $(this);
    currentColumnId = $currentSelection.parent().attr('data-column')
    if $(this).val() == ''
      ignoreColumn($currentSelection)
    else if $(this).val() == '-1'
      $('#add_custom_field').attr('data-triggeredById', currentColumnId)
      $(this).val($(this).parent().attr('data-previous'))
      clearCustomFieldForm()
      $('#add_custom_field').modal({keyboard: true, show: true})
      scrollRightToNextHeader($currentSelection)
    else
      $currentSelection.parent().attr('data-previous', $(this).val())
      unIgnoreColumn(currentColumnId)
      $('.column_header').each ->
        columnId = $(this).parent().attr('data-column')
        if columnId != currentColumnId && $(this).val() == $currentSelection.val()
          ignoreColumn($(this))
          return
      scrollRightToNextHeader($currentSelection)

  scrollRightToNextHeader = ($el) ->
    current_scroll_pos = $('.tab-content').scrollLeft()
    $('.tab-content').scrollLeft(current_scroll_pos + $el.width())
    return

  clearCustomFieldForm = ->
    $('#add_custom_field [data-content-key=form-errors]').empty()
    $('#add_custom_field input[type=text]').val('')

  ignoreColumn = ($el) ->
    $el.val('')
    $el.parent().attr('data-previous', '')
    columnId = $el.parent().attr('data-column')
    $('[data-column=' +  columnId + ']').each ->
      $(this).addClass('disabled')
    return

  unIgnoreColumn = (columnId) ->
    $('[data-column=' +  columnId + ']').each ->
      $(this).removeClass('disabled')
    return

  highlightColumn = (columnId) ->
    $columns = $('[data-column=' +  columnId + ']')
    $columns.each ->
      $(this).addClass('highlight_column')
    return

  unHighlightColumn = (columnId) ->
    $columns = $('[data-column=' +  columnId + ']')
    $columns.each ->
      $(this).removeClass('highlight_column')
    return

  $('#add_custom_field_form').on 'ajax:success', (e, data, textStatus, jqXHR) ->
    addCustomFieldToAllDropdowns(data.name, data.value)
    $('#add_custom_field').modal('hide')

  $('#add_custom_field_form').on 'ajax:error', (e, xhr, status, error) ->
    renderAlert('form-errors', xhr.responseText, 'alert-danger')

  addCustomFieldToAllDropdowns = (name, value) ->
    triggeringDropdownId = $('#add_custom_field').attr('data-triggeredById')
    $('.column_header').each ->
      currentId = $(this).attr('id')
      $ignoreOption = $('#' + currentId + ' option[value=""]')
      # Insert the new custom field before the ignore option in the dropdown
      $ignoreOption.before($('<option>', {value: name, text: value}))
      currentColumnId = $(this).parent().attr('data-column')
      if currentColumnId == triggeringDropdownId
        $(this).val(name)
        unIgnoreColumn(currentColumnId)
        highlightColumn(currentColumnId)
      return
