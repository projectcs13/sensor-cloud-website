//= require 'include/search_graph'

$ ->
	graphWidth = $(".search-graph").width()
	#console.log graphWidth
	search_graph = searchGraph().width(1000).margin({top:0, right:0, left:0, bottom:0})
	search_params = "?stream_id="
	for graph in $(".search-graph")
		search_params += graph.dataset.stream + ','
	search_params = search_params.slice(0, search_params.length-1)
	res = $.get '/history' + search_params
	res.done (result) ->
		datalist = result.history
		for graph in datalist
			d3.select(".search-graph#id"+graph.stream_id).datum(graph.data).call(search_graph)
		
	res.fail (e, data) ->
		console.log e

	# Setting up the slider
	$("#slider-range").slider 
		range: true,
		min: 0,
		max: 10,
		values: [ 0, 5 ],
		slide: ( event, ui ) -> 
			$( "#min_val" ).val ui.values[ 0 ]
			$( "#max_val" ).val ui.values[ 1 ]

	#$( "#slider-range" ).css("width","11em")

	#map
	mapDiv = document.getElementById('map-canvas')
	#console.log mapDiv
	map = new google.maps.Map(mapDiv, {
		center: new google.maps.LatLng(59, 18),
		zoom: 8,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		disableDefaultUI: true
	})

	bounds = new google.maps.LatLngBounds()
	
	markers = []
	searchres_length = 0
	hl_marker = new google.maps.Marker({ icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png', map:map})
	base_url = 'https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld='
	not_highlighted = '|FF776B|000000'
	highlighted = '|FFFF00|000000'
	$('#streams .search-result').each (i, elem) ->
  		location = $(elem).data('location')
  		searchres_length++
  		if location != " "
  			console.log location
  			loc = location.split ","
  			lon = loc[0]
  			lat = loc[1]
  			pos = new google.maps.LatLng(lon, lat)
  			console.log base_url+''+searchres_length+not_highlighted

  			marker = new google.maps.Marker({id: $(elem).data('streamid'), icon: base_url+''+searchres_length+not_highlighted, position: pos, map:map, title:''+searchres_length})
  			markers.push marker
  			bounds.extend(pos)
  	map.fitBounds(bounds);

	listener = google.maps.event.addListener(map, "idle", ->
  		if markers.length < 2
  			map.setZoom 1
  		google.maps.event.removeListener listener
	)

	$("#streams .search-result").click (e) ->
		e.stopPropagation
		id = $(this).data('streamid')
		highlight id

	highlight = (streamid) ->
		for elem in markers
			if(elem.id == streamid)
				map.panTo elem.position
				console.log elem.position
				hl_marker.setIcon base_url+elem.title+highlighted
				if(hl_marker.position == elem.position)
					if(hl_marker.visible == true)
						hl_marker.setVisible(false)
						elem.setVisible(true)
					else
						hl_marker.setVisible(true)
						elem.setVisible(false)
				else
					elem.setVisible(false)
					hl_marker.setVisible(true)
					hl_marker.setPosition elem.position
			else
				elem.setVisible(true)

	#console.log searchresults
	#for result in $("#stream-result > li")
	#	console.log result


	$('.star-rating').on 'click', ->

		obj =
			json:
				stream_id: $(this).attr('id')
				value: parseFloat($(this).children('a').text())
		res = $.ajax
			url: '/userranking'
			type: 'PUT'
			data: JSON.stringify obj
			contentType: "application/json",
			dataType: "json",
			success: (result, thing) ->
				console.log result, thing

