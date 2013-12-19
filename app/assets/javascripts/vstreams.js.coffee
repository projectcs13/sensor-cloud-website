# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/vstreams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'
//= require 'include/stream_graph_multiline'
//= require 'include/scrolling'
//= require 'include/filter_map'
//= require 'include/selectStream'
$ ->
  $(document).bind "vstreams_index", (e, obj) =>
     #setup map and graph containers
    #height still statically set since height() needs to render page to calculate correctly
    contentWidth = $(".right-side-content").width()
    $('#map-canvas').width(contentWidth).height(500)
    window.multiGraph = streamGraphMultiLine().width(contentWidth).height(300)
    window.graphData = []
    d3.select("#multiline-graph").datum(graphData).call(multiGraph)
    #setup functions for populating graph

    window.setupButtons = ->
      $('.search-result').off "click", selectStream
      $('.search-result').on "click", selectStream
         
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
    map_init($(".scroll-pane").children(), $(".search-result"), $("#map-canvas"), null, null, null)

  $(document).bind "vstreams_show", (e, obj) => #js only loaded on "show" action
    # Set up graph element
    graphWidth = $("#graph-canvas").width()
    window.graph_object = new stream_graph(graphWidth)
    graph_object.init()

    # Set up buttons
    $("#prediction-description").hide()

    $("#prediction-btn").on 'click', ->
      $("#prediction-description").show()

    $("#live-update-btn").on 'switch-change', (e, data) ->
      value = data.value
      toggle value

  $(document).bind "vstreams_new_vstream", (e, obj) => #js only loaded on "new_vstream" action
    $("#modal-window").html("<%= escape_javascript(render 'vstreams#new_vstream') %>");


  $(document).bind "vstreams_index", (e, obj) =>
    showDetails = (event) ->
      el = $(this)
      el.find('.details').toggle(500)
      el.find('.show-details')
        .toggleClass('glyphicon-chevron-up')
        .toggleClass('glyphicon-chevron-down')

    $('body').on 'click', '.list-group-item', showDetails
    
  action = "vstreams_" + $("body").data("action")
  $.event.trigger action
