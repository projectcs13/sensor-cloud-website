# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  form = $('#new_resource')

  suggest = (event) ->
    do event.preventDefault
    form.attr('action', '/suggest')
    form.data('remote', 'true')
    do form.submit

  create = (event) ->
    do event.preventDefault
    form.attr('action', '/resources')
    # form.data('remote', null)
    do form.submit

  $('body').on 'click', '#create-btn', create
  $('body').on 'click', '#suggest-btn', suggest

###
$ ->

  suggest = (event) ->
    do event.preventDefault
    model = $('#resource_model').val()
    res = $.getJSON "http://localhost:3000/suggest/#{model}"
    res.done (json) ->
      json = json[0]
      for k, v of json
        $("#resource_#{k}").val v
      @

  $('body').on 'click', '#suggest-btn', suggest
###


###
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

  # $('body').on 'click', '#addStreamButton', addStream
  # $('body').on 'click', '.glyphicon-remove', removeStream
###
