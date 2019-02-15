# Return array of string values, or NULL if CSV string not well formed.
window.CSVRowtoArray = (text) ->
  re_valid = /^\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*$/
  re_value = /(?!\s*$)\s*(?:'([^'\\]*(?:\\[\S\s][^'\\]*)*)'|"([^"\\]*(?:\\[\S\s][^"\\]*)*)"|([^,'"\s\\]*(?:\s+[^,'"\s\\]+)*))\s*(?:,|$)/g
  # Return NULL if input string is not well formed CSV string.
  if !re_valid.test(text)
    return null
  a = []
  # Initialize array to receive values.
  if text != undefined
    text.replace re_value, (m0, m1, m2, m3) ->
      # Remove backslash from \' in single quoted values.
      if m1 != undefined
        a.push m1.replace(/\\'/g, '\'')
      else if m2 != undefined
        a.push m2.replace(/\\"/g, '"')
      else if m3 != undefined
        a.push m3
      ''
    # Return empty string.
  # Handle special case of empty last value.
  if /,\s*$/.test(text)
    a.push ''
  a