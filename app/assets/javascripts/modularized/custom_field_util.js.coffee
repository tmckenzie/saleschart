window.validUploadRows = (text) ->
  ret = new Array
  ret[0] = true
  ret[1] = ''
  lines = text.split(/[\r\n]+/g)
  # tolerate both Windows and Unix linebreaks
  message = ''
  count = 0
  invalid_count = 0
  invalid_line = ''
  additional_invalid_lines = ''
  i = 0
  while i < lines.length
    if lines[i] == ''
      lines = lines.splice(i, 1)
      i--
    else
      count++
    array = CSVRowtoArray(lines[i])
    if (array == null && lines[i] != null && lines[i].indexOf("'") > -1 )
      array = lines[i].split(",")
    if array != null and array.length > 2
      ret[0] = false
      if invalid_line == ''
        invalid_line = i + 1
      invalid_count++
      if invalid_count > 1
        tot = invalid_count - 1
        additional_invalid_lines = ' plus ' + tot + ' line(s)'
      ret[1] = 'Please only name value pairs allowed. On line ' + invalid_line + additional_invalid_lines
    i++
  if (count > 300)
    ret[0] = false
    ret[1] = 'Too many rows only 300 allowed.'

  return ret
