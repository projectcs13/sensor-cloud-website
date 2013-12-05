//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'
//= require 'include/filter_map'


$ ->
  #setup map and graph containers
  #height still statically set since height() needs to render page to calculate correctly
  contentWidth = $(".right-side-content").width()
  $('#map-canvas').width(contentWidth).height(500)
  multiGraph = streamGraphMultiLine().width(contentWidth).height(300)
  graphData = []
  d3.select("#multiline-graph").datum(graphData).call(multiGraph)
  #setup functions for populating graph
  for graph in $('#streams .search-result')
    $(graph).on "click", (event) ->
      stream_id = this.dataset.streamid
      iteration = this.dataset.iteration
      isSelected = $(this).children().hasClass("selected")
      selectedSpan = "<span class='pull-right glyphicon glyphicon-ok-sign selected" + iteration + "'></span>"
      noDataSpan = "<span class='pull-right no-data'>[NO DATA]</span>"
      panelHeader = $(this).children().first()
      if isSelected
        $(this).children().removeClass("selected")
        panelHeader.children().remove("span")
        graphData = graphData.filter (el) -> 
          return el.stream_id.toString() != stream_id
        $("#multiline-graph svg").remove()
        d3.select("#multiline-graph").datum(graphData).call(multiGraph)
      else
        $(this).children().addClass("selected")
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
