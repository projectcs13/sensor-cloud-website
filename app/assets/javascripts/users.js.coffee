# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  $(document).bind "users_following", (e, obj) =>
    window.createMap
      dom: $('#map-canvas').parent()
      location: null
      editable: false


  body = $('body')
  cont = body.data('controller')
  meth = body.data('action')
  event = "#{cont}_#{meth}"
  $.event.trigger event
