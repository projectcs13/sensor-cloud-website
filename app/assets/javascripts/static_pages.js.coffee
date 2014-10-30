# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

	TIME = 500

	# console.log document.cookie.indexOf("visited")

	if document.cookie.indexOf("visited") < 0
	  $('#cookies-info').show 0

	  expiry = new Date()
	  expiry.setTime expiry.getTime() + 10*60*1000  # Ten minutes
	  document.cookie = "visited=yes; expires=" + expiry.toGMTString()

	  $('#btn-cookies-continue').on 'click', (event) ->
	  	console.log "hi2"
	  	do event.preventDefault
	  	$('#cookies-info').hide TIME
