//= require 'include/search_graph'
//= require 'include/stream_graph_multiline'
//= require 'include/scrolling'
//= require 'include/filter_map'
//= require 'include/selectStream'


$ ->
  $("#filter-btn").on 'click', ->
    $("#filter").slideToggle()

  #setup map and graph containers
  #height still statically set since height() needs to render page to calculate correctly
  contentWidth = $(".right-side-content").width()
  $('#map-canvas').width(contentWidth).height(500)
  window.multiGraph = streamGraphMultiLine().width(contentWidth).height(300)
  window.graphData = []
  d3.select("#multiline-graph").datum(graphData).call(multiGraph)

  #setup functions for populating graph
  window.setupButtons = ->
    $('#streams .search-result').off "click", selectStream
    $('#streams .search-result').on "click", selectStream
    $('#vstreams .search-result').off "click", selectVStream
    $('#vstreams .search-result').on "click", selectVStream
       
    $('input.star').rating()
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

  setupButtons()
  init_scrolling()

  map_init($('#streams .search-result'), $('#streams .search-result'), $("#map-canvas"), $("#lati"), $("#long"), $("#radkm"))
  
