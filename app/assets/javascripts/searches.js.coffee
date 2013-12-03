//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'
//= require 'include/filter_map'
$ ->
  graphWidth = $(".right-side-content").width()
  console.log graphWidth
  graphData = []
  multiGraph = streamGraphMultiLine().width(graphWidth).height(500)
  d3.select("#multiline-graph").datum(graphData).call(multiGraph)
  for graph in $('#streams .search-result')
    $(graph).on "click", (event) ->
      stream_id = this.dataset.streamid
      iteration = this.dataset.iteration
      console.log iteration
      isSelected = $(this).children().first().hasClass("selected")
      selectedSpan = "<span class='pull-right glyphicon glyphicon-ok-sign selected" + iteration + "'></span>"
      noDataSpan = "<span class='pull-right no-data'>[NO DATA]</span>"
      panelHeader = $(this).children().first()
      if isSelected
        panelHeader.removeClass("selected")
        panelHeader.children().remove("span")
        graphData = graphData.filter (el) -> 
          return el.stream_id.toString() != stream_id
        $("#multiline-graph svg").remove()
        d3.select("#multiline-graph").datum(graphData).call(multiGraph)
      else
        panelHeader.addClass("selected")
        # ajax call
        res = $.get '/datapoints/' + stream_id
        res.done (result) ->
          result['stream_id'] = stream_id
          graphData.push result
          if result['data'].length == 0
            panelHeader.append(noDataSpan)
          else
            panelHeader.append(selectedSpan)
          $("#multiline-graph svg").remove()
          d3.select("#multiline-graph").datum(graphData).call(multiGraph)
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
	# #map
	# mapDiv = document.getElementById('map-canvas')
	# 	disableDefaultUI: true
	# })

	# bounds = new google.maps.LatLngBounds()
  
	# markers = []
	# searchres_length = 0
	# hl_marker = new google.maps.Marker({ icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png', map:map})
	# base_url = 'https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld='
	# not_highlighted = '|FF776B|000000'
	# highlighted = '|FFFF00|000000'
	# $('#streams .search-result').each (i, elem) ->
 #  		location = $(elem).data('location')
 #  		searchres_length++
 #  		if location != " "
 #  			console.log location
 #  			loc = location.split ","
 #  			lon = loc[0]
 #  			lat = loc[1]
 #  			pos = new google.maps.LatLng(lon, lat)
 #  			console.log base_url+''+searchres_length+not_highlighted

 #  			marker = new google.maps.Marker({id: $(elem).data('streamid'), icon: base_url+''+searchres_length+not_highlighted, position: pos, map:map, title:''+searchres_length})
 #  			markers.push marker
 #  			bounds.extend(pos)
 #  	map.fitBounds(bounds);

	# listener = google.maps.event.addListener(map, "idle", ->
 #  		if markers.length < 2
 #  			map.setZoom 1
 #  		google.maps.event.removeListener listener
	# )

	# $("#streams .search-result").click (e) ->
	# 	e.stopPropagation
	# 	id = $(this).data('streamid')
	# 	highlight id

	# highlight = (streamid) ->
	# 	for elem in markers
	# 		if(elem.id == streamid)
	# 			map.panTo elem.position
	# 			console.log elem.position
	# 			hl_marker.setIcon base_url+elem.title+highlighted
	# 			if(hl_marker.position == elem.position)
	# 				if(hl_marker.visible == true)
	# 					hl_marker.setVisible(false)
	# 					elem.setVisible(true)
	# 				else
	# 					hl_marker.setVisible(true)
	# 					elem.setVisible(false)
	# 			else
	# 				elem.setVisible(false)
	# 				hl_marker.setVisible(true)
	# 				hl_marker.setPosition elem.position
	# 		else
	# 			elem.setVisible(true)

  #console.log searchresults
  #for result in $("#stream-result > li")
  #  console.log result


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
	map_init()