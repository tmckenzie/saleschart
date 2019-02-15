(($) =>
  $.formatDate =
    monthNames: ["January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December"]

  $.fn.formatDate = ->
    $(this).bind 'blur', ->
      dateString = $(this).val()
      if match = dateString.match(/^(\d{2})(\d{2})$/)
        $(this).val(match[1] + '/20' + match[2])
      else if match = dateString.match(/^(\d{2})\/(\d{2})$/)
        $(this).val(match[1] + '/20' + match[2])
      else if match = dateString.match(/^(January|February|March|April|May|June|July|August|September|October|November|December)\s(\d{2})$/) #Ben made me do it...
        month = $.formatDate.monthNames.indexOf(match[1])+1
        $(this).val(month + '/20' + match[2])
) jQuery