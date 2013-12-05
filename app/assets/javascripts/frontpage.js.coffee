//= require caroufredsel
$ -> 
	$("#foo").carouFredSel
		circular: true
		height: "auto"
		width: "100%"
		align: 	"center"
		effect: "fade"

		

		items: 

			visible: 6,
			minimum: 1,
			start: "random",
			width: "100%",
			height: "variable"
		scroll: 
			items: 1,
			easing : "linear",
			duration: 4000,
			pauseOnHover: 'immediate'
			fx: "directscroll"
			

		auto: 0
			

	#carousel = new Carousel $('#carousel_items'),
	#	onChange: (items) ->
		
	#	otherCarouFredSelOptions: 'go here'
