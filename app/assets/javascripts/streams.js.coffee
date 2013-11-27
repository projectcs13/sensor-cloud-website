# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'

$ ->

  listResources = (json) ->
    list = ""
    for res in json
      console.log res.payload.resource
      list = list + "<div onclick='fetchStreamsFromResource "+res.payload.resource+"' class='btn btn-primary'>"+
                      res.payload.model+
                    "</div>"+
                    "<div class='clearfix'></div>"
    $('#resources_list').html list
    fetchStreamsFromResource json[0].payload.resource

  fetchStreamsFromResource = (id) ->
    streams = $.getJSON "/resources/#{id}"
    streams.done listStreams

  listStreams = (json) ->
    list = ""
    for res in json.streams_suggest
      console.log res.name
      list = list + 
        "<div><input type='checkbox'>"+res.type+"</div>"
    console.log json
    $('#streams_list').html list

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    do split(term).pop

  selectItem = (ui, value) ->
    terms = split value
    do terms.pop                # remove the current input
    terms.push ui.item.text    # add the selected item
    terms.push ""               # add placeholder to get the comma-and-space at the end
    terms

  autocomplete = () ->
      $("#resource_model").bind "keydown", (event) ->
          console.log "keydown"
          event.preventDefault() if event.keyCode is $.ui.keyCode.TAB and $(this).data("ui-autocomplete").menu.active

        .autocomplete
          minLength: 1

          source: (request, response) ->
            console.log request.term
            $.getJSON "/suggest/#{request.term}", response

          focus: ->
            # prevent value inserted on focus
            false

          select: (event, ui) ->
            console.log ui
            console.log @value
            terms = selectItem ui, @value
            console.log terms
            false

  autocomplete()


  showDetails = (event) ->
    el = $(this)
    el.find('.details').toggle(500)
    el.find('.show-details')
      .toggleClass('glyphicon-chevron-up')
      .toggleClass('glyphicon-chevron-down')

  $('body').on 'click', '.list-group-item', showDetails

  # Set up graph element
  #graphWidth = $("#graph-canvas").width();
  #window.graph_object = new stream_graph(graphWidth);
  #graph_object.init();

  # Set up buttons
  $("#prediction-description").hide();

  $("#prediction-btn").on 'click', ->
    $("#prediction-description").show()
    graph_object.fetch_prediction_data()

  $("#live-update-btn").on 'switch-change', (e, data) ->
    value = data.value
    alert value
    toggle(value)
