# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  modal  = $ '#modal'
  list   = $ '#resources-streams-list'
  num    = 0
  stream = null


  template = ->
    children = list.children()
    stream   = children.first().clone()
    stream.find('input').val "" if stream

    num      = children.length + 1
    stream


  updateNumbers = (streams) ->
    # streams.map () ->
      # Update their label


  #
  # Function: addStream
  #
  # Clone the HTML structure of a stream, create a new one dynamically
  # and add it to the list of streams
  #
  addStream = (event) ->
    do event.preventDefault
    # stream.find('#num').text num
    list.append(stream)
    stream = do template
    @


  removeStream = (event) ->
    do event.preventDefault
    do $(this).parents('.resources-stream').remove


  # Initialization

  stream = do template

  $('body').on 'click', '#addStreamButton', addStream
  $('body').on 'click', '.glyphicon-remove', removeStream
