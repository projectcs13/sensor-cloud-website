# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

	TIME = 500

	if document.cookie.indexOf("visited") < 0
	  $('#cookies-info').show 0

	  $('#btn-cookies-continue').on 'click', (event) ->
	  	do event.preventDefault

		  expiry = new Date()
		  expiry.setTime expiry.getTime() + 24*60*60*1000  # A day
		  document.cookie = "visited=yes; expires=" + expiry.toGMTString()

	  	$('#cookies-info').hide TIME
