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

  # suggest = (event) ->
  suggest = (model) ->
    # do event.preventDefault
    # model = $('#resource_model').val()
    res = $.getJSON "/suggest/#{model}"
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

  # $('body').on 'click', '#suggest-btn', suggest


  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    do split(term).pop

  selectItem = (ui, value) ->
    terms = split value
    do terms.pop                # remove the current input
    terms.push ui.item.value    # add the selected item
    terms.push ""               # add placeholder to get the comma-and-space at the end
    terms

  autocomplete = (attr) ->
      $("#resource_#{attr}")

        # don't navigate away from the field on tab when selecting an item
        .bind "keydown", (event) ->
          event.preventDefault() if event.keyCode is $.ui.keyCode.TAB and $(this).data("ui-autocomplete").menu.active

        .autocomplete
          minLength: 1

          source: "/autocomplete/#{attr}"

          focus: ->
            # prevent value inserted on focus
            false

          select: (event, ui) ->
            terms = selectItem ui, @value

            appendWithComma = => @value = terms.join ", "
            appendValue     = => @value = terms.join ""

            switch attr
              when "tags"         then do appendWithComma
              when "manufacturer" then do appendValue
              when "model"
                do appendValue
                suggest @value

            false

  autocomplete attr for attr in [ "model", "manufacturer", "tags" ]
