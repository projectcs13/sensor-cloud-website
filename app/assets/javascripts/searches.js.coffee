//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'

$ ->
  graphWidth = $(".search-graph").width()
  graphData = []
  test_graph = streamGraphMultiLine().width(700).height(500)
  for graph in $('#streams .search-result')
    $(graph).on "click", (event) ->
      stream_id = this.dataset.streamid
      iteration = this.dataset.iteration
      console.log iteration
      isSelected = $(this).children().first().hasClass("selected")
      selectedDiv = "<span class='pull-right glyphicon glyphicon-ok-sign selected" + iteration + "'></span>"
      console.log selectedDiv
      if isSelected
        $(this).children().first().removeClass("selected")
        $(this).children().first().children().remove("span")
        graphData = graphData.filter (el) -> 
          return el.stream_id.toString() != stream_id
        $("#test-multiline svg").remove()
        d3.select("#test-multiline").datum(graphData).call(test_graph)
      else
        $(this).children().first().addClass("selected")
        $(this).children().first().append(selectedDiv)
        # ajax call
        res = $.get '/datapoints/' + stream_id
        res.done (result) ->
          result['stream_id'] = stream_id
          graphData.push result
          $("#test-multiline svg").remove()
          d3.select("#test-multiline").datum(graphData).call(test_graph)
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

