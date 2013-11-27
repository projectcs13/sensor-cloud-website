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
	
	markers = 0

	$('#streams .search-result').each (i, elem) ->
  		location = $(elem).data('location')
  		if location != " "
  			console.log location
  			loc = location.split ","
  			lon = loc[0]
  			lat = loc[1]
  			pos = new google.maps.LatLng(lon, lat)
  			marker = new google.maps.Marker({position: pos,map: map,title:$(elem).data('streamid')})
  			markers++
  			bounds.extend(pos)
  	map.fitBounds(bounds);

	listener = google.maps.event.addListener(map, "idle", ->
  		if markers < 2
  			map.setZoom 1
  		google.maps.event.removeListener listener
	)

	#console.log searchresults
	#for result in $("#stream-result > li")
	#	console.log result


