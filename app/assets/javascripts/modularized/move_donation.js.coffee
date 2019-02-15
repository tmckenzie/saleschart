$(document).ready ->
  # Execute this only if move donation button is present
  if $('#move-donation-typeahead') == undefined
    return

  options_map = {}
  $('#move-donation-typeahead').autocomplete
    source: (query, process) ->
      states = []
      data = $("#move-donation-typeahead[data-options]").data()
      $.each data.options, (i, option) ->
        options_map[option.display_name] = option
        states.push option.display_name
        return
      suggest = []
      $.each states, (i, state) ->
        kw = options_map[state].keyword
        if (kw != null && kw.toLowerCase().indexOf(query['term'].trim().toLowerCase()) != -1)
          suggest.push state
      process suggest.slice(0,20)
      return

    select: (e, item) ->
      $('input[name=target_ck_id]').val(options_map[item['item']['value']].ck_id)
      $('input[name=target_pf_id]').val(options_map[item['item']['value']].pf_id)
      $('input[name=target_kw_desc]').val(options_map[item['item']['value']].display_name)
      return item