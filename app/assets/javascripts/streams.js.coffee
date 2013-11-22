# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'
$ ->
	# Set up map element
	#mapWidth = $('#map-canvas').width();
	#$('#map-canvas').height(mapWidth);
	#initialize_map(latitude, longitude);

$ ->

  showDetails = (event) ->
    el = $(this)
    el.find('.details').toggle(500)
    el.find('.show-details')
      .toggleClass('glyphicon-chevron-up')
      .toggleClass('glyphicon-chevron-down')


  # Set up graph element
	graphWidth = $("#graph-canvas").width();
	window.graph_object = new stream_graph(graphWidth);
	graph_object.init();

  # Set up buttons
	$("#prediction-description").hide();
	
	$("#prediction-btn").on 'click', ->
		$("#prediction-description").show()
		graph_object.fetch_prediction_data()
	
	$("#live-update-btn").on 'switch-change', (e, data) ->
		value = data.value
		alert value
		toggle(value)
