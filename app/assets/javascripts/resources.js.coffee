# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

###
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
      console.log json
      for k, v of json
        if v
          input = $("#resource_#{k}")
          input.val v
          input.addClass 'highlight'
          input.on 'focus', ->
            $(this).removeClass 'highlight'
      @

  $('body').on 'click', '#suggest-btn', suggest
