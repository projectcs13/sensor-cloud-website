# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'

$ ->
  showDetails = (event) ->
    el = $(this)
    el.find('.details').toggle(500)
    el.find('.show-details')
      .toggleClass('glyphicon-chevron-up')
      .toggleClass('glyphicon-chevron-down')
  $('body').on 'click', '.list-group-item', showDetails

  $(document).bind "streams_show", (e, obj) => #js only loaded on "show" action
    # Set up graph element
    graphWidth = $("#graph-canvas").width();
    window.graph_object = new stream_graph(graphWidth);
    graph_object.init();

    # Set up buttons
    $("#prediction-description").hide();

    $("#prediction-btn").on 'click', ->
      $("#prediction-description").show()
      graph_object.fetch_prediction_data()

    loc = document.getElementById('location').getAttribute('value').split ","
    
    mapDiv = document.getElementById('map-canvas')
    
    mapOptions =
      center: new google.maps.LatLng loc[0], loc[1]
      zoom: 3,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable:false
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    $("#live-update-btn").on 'switch-change', (e, data) ->
      value = data.value
      alert value
      toggle(value)
  $(document).bind 'streams_new', (e,obj) => 
    mapDiv = document.getElementById('map-canvas')
    
    mapOptions =
      center: new google.maps.LatLng 60, 18
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable:true
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    google.maps.event.addListener marker, "dragend", (evt) ->
      $('#lat').val(evt.latLng.lat())
      $('#lon').val(evt.latLng.lng())

  action = "streams_" + $("body").data("action")
  $.event.trigger action

