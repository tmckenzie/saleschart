$ -> 
	$('.mc-pledge-button').on 'click', (e)-> 
		e.preventDefault()
		$this = $(this)
		$url = $this.attr('href')
		$size = $this.data('mc-button-size')
		$color = $this.data('mc-button-color')

		$('.mc-pledge-button').removeClass('selected')
		$this.addClass('selected')

		$.ajax
			method: 'PUT', 
			format: 'script', 
			url: $url
			data: {size: $size, color: $color}
		.done  (data)-> 
			updateContent(null, data)
			true
		.fail (x, status, error)-> 
			alert error;
			true