//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'

$ ->
  graphColors = ["#aabbcc", "#a21bc4", "#8bbbbc", "#5ab1cc", "#a3b1cc", "#aabbff", "#a124cc"]
  graphWidth = $(".search-graph").width()
  #console.log graphWidth
  graphData = []
  nr = 0
  test_graph = streamGraphMultiLine().width(700).height(500)
  search_graph = searchGraph().width(1000).margin({top:0, right:0, left:0, bottom:0})
  search_params = "?stream_id="
  for graph in $('#streams .search-result')
    $(graph).on "click", (event) ->
      stream_id = this.dataset.streamid
      console.log $(this)
      res = $.get '/datapoints/' + stream_id
      res.done (result) ->
        result['stream_id'] = stream_id
        graphData.push result
        $("#test-multiline svg").remove()
        d3.select("#test-multiline").datum(graphData).call(test_graph)
        console.log result
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
  mapWidth = $(".right-side-content").width()
  mapHeight = 500
  console.log mapWidth
  $('#map-canvas').width(mapWidth)
  $('#map-canvas').height(mapHeight)
  #console.log mapDiv
  map = new google.maps.Map(mapDiv, {
      center: new google.maps.LatLng(59, 18),
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      disableDefaultUI: true
    })

  bounds = new google.maps.LatLngBounds()
  
  $('#streams .search-result').each (i, elem) ->
     location = $(elem).data('location')
     if location != " "
       console.log location
       loc = location.split ","
       lon = loc[0]
       lat = loc[1]
       pos = new google.maps.LatLng(lon, lat)
       marker = new google.maps.Marker({position: pos,map: map,title:"Hello World!"})
       bounds.extend(pos)
    map.fitBounds(bounds);

  #console.log searchresults
  #for result in $("#stream-result > li")
  #  console.log result

