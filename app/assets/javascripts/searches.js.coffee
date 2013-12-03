//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'

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

