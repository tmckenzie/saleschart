#= require jquery
$ -> 
  $('.close').click -> 
  	do close_modal

  $(document).keyup (e)-> 
  	if e.which == 27
  		do close_modal

  do center_on_page('#modal')
  do center_on_page('#message')

close_modal = -> 
	window.location.replace(document.getElementById("background-iframe").src)

center_on_page = (selector) -> 
	$this = $(selector)
	w = $this.width()
	h = $this.height()
	$this.css('margin-left', -(w/2) + 'px')
	$this.css('margin-top', -(h/2) + 'px')


